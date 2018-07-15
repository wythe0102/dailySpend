package spend.service.impl;

import java.io.IOException;
import java.math.BigDecimal;
import java.text.DecimalFormat;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;
import java.util.Map;
import java.util.concurrent.TimeUnit;

import com.alibaba.fastjson.JSON;
import com.alibaba.fastjson.JSONArray;
import com.alibaba.fastjson.JSONObject;
import okhttp3.*;
import org.apache.log4j.Logger;
import org.hibernate.SQLQuery;
import org.hibernate.SessionFactory;
import org.hibernate.transform.Transformers;
import org.springframework.beans.BeanUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import spend.dao.BaseDaoI;
import spend.model.DailySpend;
import spend.model.Type;
import spend.model.Users;
import spend.pageModel.MDailySpend;
import spend.service.DailySpendI;
import spend.util.DataGrid;
import spend.util.LineCharts;
import spend.util.LineChartsData;
import spend.util.Result;
@Service(value="dailySpendService")
public class DailySpendImpl implements DailySpendI {
	private static final String SYNC_DOMAIN = "52tool.net";
	private static final Logger logger=Logger.getLogger(DailySpendImpl.class);
	private BaseDaoI<DailySpend> dailySpendDao;
	private BaseDaoI<Type> typeDao;
	private BaseDaoI<Users> userDao;
	private SessionFactory sessionFactory;

	
	public SessionFactory getSessionFactory() {
		return sessionFactory;
	}
	@Autowired
	public void setSessionFactory(SessionFactory sessionFactory) {
		this.sessionFactory = sessionFactory;
	}
	public BaseDaoI<DailySpend> getDailySpendDao() {
		return dailySpendDao;
	}
	@Autowired
	public void setDailySpendDao(BaseDaoI<DailySpend> dailySpendDao) {
		this.dailySpendDao = dailySpendDao;
	}
	
	public BaseDaoI<Type> getTypeDao() {
		return typeDao;
	}
	@Autowired
	public void setTypeDao(BaseDaoI<Type> typeDao) {
		this.typeDao = typeDao;
	}
	public BaseDaoI<Users> getUserDao() {
		return userDao;
	}
	@Autowired
	public void setUserDao(BaseDaoI<Users> userDao) {
		this.userDao = userDao;
	}
	@Override
	public DataGrid dataGrid(MDailySpend mDailySpend) {
		// TODO Auto-generated method stub
		DataGrid dg=new DataGrid();
		String hql="select ds ";
		String totalHql="select count(*) ";
		String sumHql="select SUM(ds.amount) ";
		
		String wherehql="from DailySpend ds left join ds.type left join ds.users where 1=1";
		if (mDailySpend.getStartDate()!=null && !mDailySpend.getStartDate().equals("")) {
			wherehql+=" and ds.date >= '"+mDailySpend.getStartDate()+"'";
		}
		if (mDailySpend.getEndDate()!=null && !mDailySpend.getEndDate().equals("")) {	
			wherehql+=" and ds.date <= '"+mDailySpend.getEndDate()+"'";
		}
		if (mDailySpend.getTypeId()!=null && !mDailySpend.getTypeId().equals("")) {
			wherehql+=" and ds.type.typeId in ("+mDailySpend.getTypeId()+")";
		}
		if (mDailySpend.getUserId()!=null && !mDailySpend.getUserId().equals("")) {
			wherehql+=" and ds.users.userId = "+mDailySpend.getUserId();
		}
		
		String orderHql="";

		if (mDailySpend.getSort()!=null && !mDailySpend.getSort().equals("")) {
			orderHql+=" order by ds."+mDailySpend.getSort();
		}
		if (mDailySpend.getOrder()!=null && !mDailySpend.getOrder().equals("")) {
			orderHql+=" "+mDailySpend.getOrder();
		}
		
		totalHql+=wherehql + orderHql;
		hql+=wherehql + orderHql;
		sumHql+=wherehql;
		
		List<DailySpend> ds=dailySpendDao.find(hql, mDailySpend.getPage(), mDailySpend.getRows());
		List<MDailySpend> mds=new ArrayList<MDailySpend>();
		
		List footerList=new ArrayList();
		
		double sumPageAmount=0d;
		
		if (ds!=null && ds.size()>0) {
			for (DailySpend tempDailySpend : ds) {
				MDailySpend tempMDailySpend=new MDailySpend();
				BeanUtils.copyProperties(tempDailySpend, tempMDailySpend);
				tempMDailySpend.setTypeId(tempDailySpend.getType().getTypeId().toString());
				tempMDailySpend.setUserId(tempDailySpend.getUsers().getUserId().toString());
				tempMDailySpend.setTypeName(tempDailySpend.getType().getName());
				tempMDailySpend.setUserName(tempDailySpend.getUsers().getName());
				sumPageAmount+=tempDailySpend.getAmount().doubleValue();
				mds.add(tempMDailySpend);
			}
		}
		
		sumPageAmount=new BigDecimal(sumPageAmount).setScale(2, BigDecimal.ROUND_HALF_UP).doubleValue();
		//设置单页汇总金额
		MDailySpend fDailySpend=new MDailySpend();
		fDailySpend.setTypeName("本页总计：");
		fDailySpend.setAmount(sumPageAmount);
		fDailySpend.setDate(null);
		//取得全部汇总金额
		Double sumTotalAmount=(Double)(sessionFactory.getCurrentSession().createQuery(sumHql).uniqueResult());
		String totalAmount="";
		if (sumTotalAmount!=null) {
			DecimalFormat df = new DecimalFormat();  
			df.setMaximumFractionDigits(5); // 设置最大小数位  
			totalAmount = df.format(sumTotalAmount.doubleValue());
		}
		fDailySpend.setDemo("全部总计：");
		fDailySpend.setUserName("<span style='color:red'>"+totalAmount+"</span>");
		
		footerList.add(fDailySpend);
		
		dg.setTotal(dailySpendDao.count(totalHql));
		dg.setRows(mds);
		dg.setFooter(footerList);
		
		return dg;
	}

	@Override
	public Result addDailySpend(MDailySpend mDailySpend) {
		// TODO Auto-generated method stub
		Result result=new Result();
		for (int i = 0; i < mDailySpend.getAmounts().length; i++) {
			if (!mDailySpend.getAmounts()[i].equals("") && !mDailySpend.getUserIds()[i].equals("") && !mDailySpend.getTypeIds()[i].equals("")) {
				try {
					DailySpend ds=new DailySpend();
					ds.setAmount(Double.parseDouble(mDailySpend.getAmounts()[i]));
					SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
					Date date = sdf.parse(mDailySpend.getDates()[i]);
					ds.setDate(date);
					ds.setDemo(mDailySpend.getDemos()[i]);
					ds.setType(typeDao.get(Type.class, Long.parseLong(mDailySpend.getTypeIds()[i])));
					ds.setUsers(userDao.get(Users.class, Long.parseLong(mDailySpend.getUserIds()[i])));
					
					dailySpendDao.save(ds);
				} catch (Exception e) {
					// TODO Auto-generated catch block
					//e.printStackTrace();
					e.printStackTrace();
					result.setMsg(e.getMessage());
					result.setSuccess(false);
				}
			}
			result.setMsg("添加成功");
			result.setSuccess(true);
		}
		return result;
	}

	@Override
	public Result editDailySpend(MDailySpend mDailySpend) {
		// TODO Auto-generated method stub
		DailySpend dSpend=dailySpendDao.get(DailySpend.class, mDailySpend.getSpendDetailId());
		dSpend.setType(typeDao.get(Type.class, Long.parseLong(mDailySpend.getTypeId())));
		dSpend.setUsers(userDao.get(Users.class, Long.parseLong(mDailySpend.getUserId())));
		Result result=new Result();
		BeanUtils.copyProperties(mDailySpend, dSpend,new String[] { "spendDetailId" });
		dailySpendDao.saveOrUpdate(dSpend);
		result.setSuccess(true);
		result.setMsg("修改成功！");
		result.setObj(dSpend);
		return result;
	}

	@Override
	public Result deleteDailySpend(MDailySpend mDailySpend) {
		// TODO Auto-generated method stub
		String deleteHql="DELETE from daily_spend where spendDetailId in ("+mDailySpend.getDailySpendIds()+")";
		SQLQuery deleteQuery=sessionFactory.getCurrentSession().createSQLQuery(deleteHql);
		int count=deleteQuery.executeUpdate();
		Result result=new Result();
		result.setMsg("删除成功！");
		result.setSuccess(true);
		return result;
	}
	@Override
	public DataGrid dataSumGrid(MDailySpend mDailySpend) {
		// TODO Auto-generated method stub
		DataGrid dg=new DataGrid();
		String hql="select ds.*,SUM(ds.amount) as sumAmount ";
		String totalHql="select count(*) from (select count(*) ";
		
		String wherehql="from daily_spend ds LEFT JOIN type t on ds.typeId = t.typeId LEFT JOIN users u on ds.userId = u.userId" +
				" where 1=1";
		if (mDailySpend.getStartDate()!=null && !mDailySpend.getStartDate().equals("")) {
			wherehql+=" and ds.date >= '"+mDailySpend.getStartDate()+"'";
		}
		if (mDailySpend.getEndDate()!=null && !mDailySpend.getEndDate().equals("")) {	
			wherehql+=" and ds.date <= '"+mDailySpend.getEndDate()+"'";
		}
		
		String groupHql=" GROUP BY ds.date";
		
		String orderHql="";

		if (mDailySpend.getSort()!=null && !mDailySpend.getSort().equals("")) {
			orderHql+=" order by "+mDailySpend.getSort();
		}
		if (mDailySpend.getOrder()!=null && !mDailySpend.getOrder().equals("")) {
			orderHql+=" "+mDailySpend.getOrder();
		}
		
		totalHql+=wherehql + groupHql + " ) as a";
		hql+=wherehql + groupHql + orderHql;

		SQLQuery sqlQuery=sessionFactory.getCurrentSession().createSQLQuery(hql);
		List dsList=sqlQuery.setResultTransformer(Transformers.ALIAS_TO_ENTITY_MAP).setFirstResult((mDailySpend.getPage()-1) * mDailySpend.getRows()).setMaxResults(mDailySpend.getRows()).list();
		
		//计算汇总
		List footerList=new ArrayList();
		double sumAmount=0d;
		for (Object object : dsList) {
			sumAmount+=((Map<String,BigDecimal>)object).get("sumAmount").doubleValue();
		}
		sumAmount=new BigDecimal(sumAmount).setScale(2, BigDecimal.ROUND_HALF_UP).doubleValue();
		MDailySpend fDailySpend=new MDailySpend();
		fDailySpend.setSumAmount(String.valueOf(sumAmount));
		fDailySpend.setDate(null);
		footerList.add(fDailySpend);
		
		String countString=sessionFactory.getCurrentSession().createSQLQuery(totalHql).uniqueResult().toString();
		Long count=Long.valueOf(countString);
		dg.setTotal(count);
		dg.setRows(dsList);
		dg.setFooter(footerList);
		return dg;
	}
	@Override
	public LineCharts dataLineCharts(MDailySpend mDailySpend) {
		LineCharts lineCharts=new LineCharts();
		LineChartsData lineChartsData=new LineChartsData();
		lineChartsData.setName(mDailySpend.getStartDate().substring(5, 7)+"月");
		
		String hql="select ds.*,SUM(ds.amount) as sumAmount ";
		
		String wherehql="from daily_spend ds LEFT JOIN type t on ds.typeId = t.typeId LEFT JOIN users u on ds.userId = u.userId" +
				" where 1=1";
		if (mDailySpend.getStartDate()!=null && !mDailySpend.getStartDate().equals("")) {
			wherehql+=" and ds.date >= '"+mDailySpend.getStartDate()+"'";
		}
		if (mDailySpend.getEndDate()!=null && !mDailySpend.getEndDate().equals("")) {	
			wherehql+=" and ds.date <= '"+mDailySpend.getEndDate()+"'";
		}
		
		String groupHql=" GROUP BY ds.date";
		
		String orderHql="";

		if (mDailySpend.getSort()!=null && !mDailySpend.getSort().equals("")) {
			orderHql+=" order by ds.date";
		}
		if (mDailySpend.getOrder()!=null && !mDailySpend.getOrder().equals("")) {
			orderHql+=" asc";
		}

		hql+=wherehql + groupHql + orderHql;

		SQLQuery sqlQuery=sessionFactory.getCurrentSession().createSQLQuery(hql);
		List dsList=sqlQuery.setResultTransformer(Transformers.ALIAS_TO_ENTITY_MAP).setFirstResult((mDailySpend.getPage()-1) * mDailySpend.getRows()).setMaxResults(mDailySpend.getRows()).list();
		
		for (Object object : dsList) {
			Map<String, String> map=(Map<String, String>)object;
			SimpleDateFormat sdf=new SimpleDateFormat("yyyy-MM-dd");
			lineCharts.getCategories().add(sdf.format(map.get("date")));
			lineChartsData.getData().add(map.get("sumAmount"));
		}
		
		lineCharts.getSeries().add(lineChartsData);
		
		return lineCharts;
	}
	@Override
	public LineCharts dataLineChartsYear(MDailySpend mDailySpend) {
		LineCharts lineCharts=new LineCharts();
		LineChartsData lineChartsData=new LineChartsData();
		lineChartsData.setName(mDailySpend.getYear()+"年");
		
		String hql="select ds.*,SUM(ds.amount) as sumAmount,month(ds.date) as curMonth ";
		
		String wherehql="from daily_spend ds where 1=1";
		wherehql+=" and ds.date >= '"+mDailySpend.getYear()+"-01-01'"
			+ " and ds.date <= '"+mDailySpend.getYear()+"-12-31'";
		
		String groupHql=" GROUP BY curMonth";
		
		String orderHql=" ORDER BY curMonth";

		hql+=wherehql + groupHql + orderHql;

		SQLQuery sqlQuery=sessionFactory.getCurrentSession().createSQLQuery(hql);
		List dsList=sqlQuery.setResultTransformer(Transformers.ALIAS_TO_ENTITY_MAP).setFirstResult((mDailySpend.getPage()-1) * mDailySpend.getRows()).setMaxResults(mDailySpend.getRows()).list();
		
		for (Object object : dsList) {
			Map<String, String> map=(Map<String, String>)object;
			lineCharts.getCategories().add(String.valueOf(map.get("curMonth")));
			lineChartsData.getData().add(map.get("sumAmount"));
		}
		
		lineCharts.getSeries().add(lineChartsData);
		
		return lineCharts;
	}

	@Override
	public List<Long> sync() {
		OkHttpClient httpClient = new OkHttpClient();
		Request request = new Request.Builder()
				.url("http://"+ SYNC_DOMAIN +"/rest/dailySpend/sync")
				.build();
		List<Long> dailySpendIds = new ArrayList<Long>();
		try {
			Response response = httpClient.newCall(request).execute();
			String result = response.body().string();
			JSONArray syncJson = JSONArray.parseArray(result);
			MDailySpend mDailySpend = new MDailySpend();
			mDailySpend.setAmounts(new String[syncJson.size()]);
			mDailySpend.setTypeIds(new String[syncJson.size()]);
			mDailySpend.setUserIds(new String[syncJson.size()]);
			mDailySpend.setDemos(new String[syncJson.size()]);
			mDailySpend.setDates(new String[syncJson.size()]);
			for (int i=0;i<syncJson.size();i++){
				JSONObject syncObject = syncJson.getJSONObject(i);
				mDailySpend.getDates()[i] = syncObject.getString("date");
				mDailySpend.getUserIds()[i] = String.valueOf(syncObject.getIntValue("userId"));
				mDailySpend.getTypeIds()[i] = String.valueOf(syncObject.getIntValue("typeId"));
				mDailySpend.getAmounts()[i] = String.valueOf(syncObject.getFloatValue("amount"));
				mDailySpend.getDemos()[i] = syncObject.getString("demo");
				dailySpendIds.add(syncObject.getLong("spendDetailId"));
			}
			addDailySpend(mDailySpend);
		} catch (IOException e) {
			e.printStackTrace();
		} finally {
			if (dailySpendIds.size() > 0){
				confirmSync(dailySpendIds);
			}
		}
		return dailySpendIds;
	}

	private String confirmSync(List<Long> dailySpendIds){
		OkHttpClient okHttpClient  = new OkHttpClient.Builder()
				.connectTimeout(10, TimeUnit.SECONDS)
				.writeTimeout(10,TimeUnit.SECONDS)
				.readTimeout(20, TimeUnit.SECONDS)
				.build();

		String json = JSONArray.toJSONString(dailySpendIds);

		RequestBody requestBody = FormBody.create(MediaType.parse("application/json; charset=utf-8")
				, json);

		Request request = new Request.Builder()
				.url("http://"+ SYNC_DOMAIN +"/rest/dailySpend/confirmSync")
				.post(requestBody)
				.build();

		try {
			Response response = okHttpClient.newCall(request).execute();
			return response.body().toString();
		} catch (IOException e) {
			e.printStackTrace();
		}
		return "";
	}

}
