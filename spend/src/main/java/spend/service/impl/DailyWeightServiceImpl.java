package spend.service.impl;

import java.sql.Time;
import java.sql.Timestamp;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;

import org.apache.log4j.Logger;
import org.hibernate.SessionFactory;
import org.springframework.beans.BeanUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import spend.dao.BaseDaoI;
import spend.model.DailyWeight;
import spend.model.Users;
import spend.pageModel.MDailyWeight;
import spend.service.DailyWeightServiceI;
import spend.util.DataGrid;
import spend.util.Result;
@Service(value="dailyWeightService")
public class DailyWeightServiceImpl implements DailyWeightServiceI {
	private static final Logger logger=Logger.getLogger(DailyWeightServiceImpl.class);
	private BaseDaoI<DailyWeight> dailyWeightDao;
	private BaseDaoI<Users> userDao;
	private SessionFactory sessionFactory;

	@Override
	public DataGrid dataGrid(MDailyWeight mDailyWeight) {
		// TODO Auto-generated method stub
		DataGrid dg=new DataGrid();
		String hql="";
		String totalHql = "select count(*)";
		String whereHql=" from DailyWeight dw where 1=1";
		if (mDailyWeight.getStartDate()!=null) {
			SimpleDateFormat sdf=new SimpleDateFormat("yyyy-MM-dd");
			String sd = sdf.format(mDailyWeight.getStartDate());
			whereHql+=" and dw.time >='"+sd+"'";
		}
		if (mDailyWeight.getEndDate()!=null) {
			SimpleDateFormat sdf=new SimpleDateFormat("yyyy-MM-dd");
			String ed = sdf.format(mDailyWeight.getEndDate());
			whereHql+=" and dw.time <='"+ed+"'";
		}
		
		String orderHql="";

		if (mDailyWeight.getSort()!=null && !mDailyWeight.getSort().equals("")) {
			orderHql+=" order by dw."+mDailyWeight.getSort();
		}
		if (mDailyWeight.getOrder()!=null && !mDailyWeight.getOrder().equals("")) {
			orderHql+=" "+mDailyWeight.getOrder();
		}
		
		hql+=whereHql+orderHql;
		totalHql+=whereHql+orderHql;
		
		List<DailyWeight> dwList=dailyWeightDao.find(hql,mDailyWeight.getPage(),mDailyWeight.getRows());
		List<MDailyWeight> mdwList=new ArrayList<MDailyWeight>();
		for (DailyWeight dailyWeight : dwList) {
			MDailyWeight mdw=new MDailyWeight();
			BeanUtils.copyProperties(dailyWeight, mdw);
			mdw.setUserName(dailyWeight.getUsers().getName());
			mdw.setUserId(dailyWeight.getUsers().getUserId().toString());
			mdwList.add(mdw);
		}
		
		dg.setRows(mdwList);
		dg.setTotal(dailyWeightDao.count(totalHql));
		
		return dg;
	}
	
	@Override
	public Result addDailyWeight(MDailyWeight mDailyWeight) {
		// TODO Auto-generated method stub
		Result result=new Result();
		try {
			DailyWeight dailyWeight=new DailyWeight();
			BeanUtils.copyProperties(mDailyWeight, dailyWeight);
			dailyWeight.setUsers(userDao.get(Users.class, Long.parseLong(mDailyWeight.getUserId())));
			dailyWeight.setTime(new Timestamp(System.currentTimeMillis()));
			dailyWeightDao.save(dailyWeight);
			result.setObj(dailyWeight);
			result.setSuccess(true);
			result.setMsg("添加成功");
		} catch (Exception e) {
			// TODO: handle exception
			e.printStackTrace();
			result.setMsg(e.getMessage());
			result.setSuccess(false);
		}
		return result;
	}

	@Override
	public Result editDailyWeight(MDailyWeight mDailyWeight) {
		// TODO Auto-generated method stub
		Result result=new Result();
		try {
			DailyWeight dailyWeight=dailyWeightDao.get(DailyWeight.class, mDailyWeight.getWeightId());
			BeanUtils.copyProperties(mDailyWeight, dailyWeight,new String[]{"weightId"});
			dailyWeight.setUsers(userDao.get(Users.class, Long.parseLong(mDailyWeight.getUserId())));
			dailyWeight.setTime(new Timestamp(System.currentTimeMillis()));
			dailyWeightDao.saveOrUpdate(dailyWeight);
			result.setSuccess(true);
			result.setMsg("修改成功");
			result.setObj(dailyWeight);
		} catch (Exception e) {
			// TODO: handle exception
			e.printStackTrace();
			result.setMsg(e.getMessage());
			result.setSuccess(false);
		}
		return result;
	}

	@Override
	public Result deleteDailyWeight(MDailyWeight mDailyWeight) {
		// TODO Auto-generated method stub
		Result result=new Result();
		try {
			DailyWeight DailyWeight=dailyWeightDao.get(DailyWeight.class, mDailyWeight.getWeightId());
			dailyWeightDao.delete(DailyWeight);
			result.setSuccess(true);
			result.setMsg("删除成功");
			result.setObj(DailyWeight);
		} catch (Exception e) {
			// TODO: handle exception
			result.setMsg(e.getMessage());
			result.setSuccess(false);
		}
		return result;
	}

	public BaseDaoI<DailyWeight> getDailyWeightDao() {
		return dailyWeightDao;
	}
	@Autowired
	public void setDailyWeightDao(BaseDaoI<DailyWeight> dailyWeightDao) {
		this.dailyWeightDao = dailyWeightDao;
	}

	@Autowired
	public void setSessionFactory(SessionFactory sessionFactory) {
		this.sessionFactory = sessionFactory;
	}

	public BaseDaoI<Users> getUserDao() {
		return userDao;
	}
	@Autowired
	public void setUserDao(BaseDaoI<Users> userDao) {
		this.userDao = userDao;
	}

}
