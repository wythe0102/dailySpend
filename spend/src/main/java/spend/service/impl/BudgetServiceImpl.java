package spend.service.impl;

import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.List;

import org.apache.log4j.Logger;
import org.hibernate.SessionFactory;
import org.springframework.beans.BeanUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import spend.dao.BaseDaoI;
import spend.model.Budget;
import spend.model.Type;
import spend.pageModel.MBudget;
import spend.service.BudgetServiceI;
import spend.util.DataGrid;
import spend.util.Result;
@Service(value="budgetService")
public class BudgetServiceImpl implements BudgetServiceI {
	private static final Logger logger=Logger.getLogger(BudgetServiceImpl.class);
	private BaseDaoI<Budget> budgetDao;
	private BaseDaoI<Type> typeDao;
	private SessionFactory sessionFactory;

	@Override
	public DataGrid dataGrid(MBudget mBudget) {
		// TODO Auto-generated method stub
		DataGrid dg=new DataGrid();
		String hql="";
		String totalHql = "select count(*)";
		String whereHql=" from Budget b where 1=1";
		if (mBudget.getStartDate()!=null) {
			SimpleDateFormat sdf=new SimpleDateFormat("yyyy-MM-dd");
			String sd = sdf.format(mBudget.getStartDate());
			whereHql+=" and b.startDate >='"+sd+"'";
		}
		if (mBudget.getEndDate()!=null) {
			SimpleDateFormat sdf=new SimpleDateFormat("yyyy-MM-dd");
			String ed = sdf.format(mBudget.getEndDate());
			whereHql+=" and b.endDate <='"+ed+"'";
		}
		
		String orderHql="";

		if (mBudget.getSort()!=null && !mBudget.getSort().equals("")) {
			orderHql+=" order by b."+mBudget.getSort();
		}
		if (mBudget.getOrder()!=null && !mBudget.getOrder().equals("")) {
			orderHql+=" "+mBudget.getOrder();
		}
		
		hql+=whereHql+orderHql;
		totalHql+=whereHql+orderHql;
		
		List<Budget> bList=budgetDao.find(hql,mBudget.getPage(),mBudget.getRows());
		List<MBudget> mbList=new ArrayList<MBudget>();
		for (Budget budget : bList) {
			MBudget mb=new MBudget();
			BeanUtils.copyProperties(budget, mb);
			mb.setTypeId(budget.getType().getTypeId().toString());
			mb.setTypeName(budget.getType().getName());
			mbList.add(mb);
		}
		
		dg.setRows(mbList);
		dg.setTotal(budgetDao.count(totalHql));
		
		return dg;
	}

	public boolean checkConflict(MBudget mBudget,String mode){
		SimpleDateFormat sdf=new SimpleDateFormat("yyyy-MM-dd");
		String checkSql="select count(*) from budget b where b.typeId = "+mBudget.getTypeId()+
				" and b.endDate >= '"+sdf.format(mBudget.getStartDate())+
				"' and b.endDate <='"+sdf.format(mBudget.getEndDate())+"'";
		if (mode.equals("edit")) {
			checkSql+=" and b.budgetId <> "+mBudget.getBudgetId();
		}
		try {
			Long count=Long.parseLong(sessionFactory.getCurrentSession().createSQLQuery(checkSql).uniqueResult().toString());
			if (count>0) {
				return true;
			}
		} catch (Exception e) {
			// TODO: handle exception
			e.printStackTrace();
		}
		
		return false;
	}
	
	@Override
	public Result addBudget(MBudget mBudget) {
		// TODO Auto-generated method stub
		Result result=new Result();
		if (checkConflict(mBudget,"add")) {
			result.setMsg("该类预算与已有预算在时间上有冲突");
			result.setSuccess(false);
			result.setObj("sss");
			return result;
		}
		try {
			Budget budget=new Budget();
			BeanUtils.copyProperties(mBudget, budget);
			Type type=typeDao.get(Type.class, Long.parseLong(mBudget.getTypeId()));
			budget.setType(type);
			budgetDao.save(budget);
			result.setObj(budget);
			result.setSuccess(true);
			result.setMsg("添加成功");
		} catch (Exception e) {
			// TODO: handle exception
			result.setMsg(e.getMessage());
			result.setSuccess(false);
		}
		return result;
	}

	@Override
	public Result editBudget(MBudget mBudget) {
		// TODO Auto-generated method stub
		Result result=new Result();
		if (checkConflict(mBudget,"edit")) {
			result.setMsg("该类预算与已有预算在时间上有冲突");
			result.setSuccess(false);
			result.setObj("sss");
			return result;
		}
		try {
			Budget budget=budgetDao.get(Budget.class, mBudget.getBudgetId());
			budget.setType(typeDao.get(Type.class, Long.parseLong(mBudget.getTypeId())));
			BeanUtils.copyProperties(mBudget, budget,new String[]{"budgetId"});
			budgetDao.saveOrUpdate(budget);
			result.setSuccess(true);
			result.setMsg("修改成功");
			result.setObj(budget);
		} catch (Exception e) {
			// TODO: handle exception
			e.printStackTrace();
			result.setMsg(e.getMessage());
			result.setSuccess(false);
		}
		return result;
	}

	@Override
	public Result deleteBudget(MBudget mBudget) {
		// TODO Auto-generated method stub
		Result result=new Result();
		try {
			Budget budget=budgetDao.get(Budget.class, mBudget.getBudgetId());
			budgetDao.delete(budget);
			result.setSuccess(true);
			result.setMsg("删除成功");
			result.setObj(budget);
		} catch (Exception e) {
			// TODO: handle exception
			result.setMsg(e.getMessage());
			result.setSuccess(false);
		}
		return result;
	}

	public BaseDaoI<Budget> getBudgetDao() {
		return budgetDao;
	}
	@Autowired
	public void setBudgetDao(BaseDaoI<Budget> budgetDao) {
		this.budgetDao = budgetDao;
	}

	public BaseDaoI<Type> getTypeDao() {
		return typeDao;
	}
	@Autowired
	public void setTypeDao(BaseDaoI<Type> typeDao) {
		this.typeDao = typeDao;
	}
	@Autowired
	public void setSessionFactory(SessionFactory sessionFactory) {
		this.sessionFactory = sessionFactory;
	}

}
