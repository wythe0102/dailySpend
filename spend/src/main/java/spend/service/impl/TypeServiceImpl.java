package spend.service.impl;

import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.List;

import org.apache.log4j.Logger;
import org.hibernate.SQLQuery;
import org.hibernate.SessionFactory;
import org.hibernate.transform.Transformers;
import org.springframework.beans.BeanUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import spend.dao.BaseDaoI;
import spend.model.Type;
import spend.pageModel.MType;
import spend.service.TypeServiceI;
import spend.util.DataGrid;
import spend.util.Result;
import spend.util.TreeNode;

@Service(value="typeService")
public class TypeServiceImpl implements TypeServiceI {

	private static final Logger logger=Logger.getLogger(TypeServiceImpl.class);
	private SessionFactory sessionFactory;
	private BaseDaoI<Type> typeDao;
	@Override
	public DataGrid treegrid(MType mtype) {
		// TODO Auto-generated method stub
		
		String sql="select typeId,name,code,addDate,CASE parentId WHEN 1 THEN '' ELSE parentId END as _parentId,'open' as state from type where typeId <> 1";
		String totalSql="select count(*) from type where typeId <> 1";
		
		SQLQuery sqlQuery=sessionFactory.getCurrentSession().createSQLQuery(sql);
		List typeList=sqlQuery.setResultTransformer(Transformers.ALIAS_TO_ENTITY_MAP).list();
		Long count=Long.valueOf(sessionFactory.getCurrentSession().createSQLQuery(totalSql).uniqueResult().toString());
		
		DataGrid dg=new DataGrid();
		dg.setRows(typeList);
		dg.setTotal(count);
		return dg;
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

	@Override
	public Result addType(MType mType) {
		// TODO Auto-generated method stub
		Type type=new Type();
		
		BeanUtils.copyProperties(mType, type);
		type.setAddDate(new Timestamp(System.currentTimeMillis()));
		type.setType(typeDao.get(Type.class, Long.parseLong(mType.get_parentId())));
		typeDao.save(type);
		
		Result result=new Result();
		result.setSuccess(true);
		result.setObj(type);
		result.setMsg("添加成功");
		
		return result;
	}

	@Override
	public List<TreeNode> tree() {
		// TODO Auto-generated method stub
		List<TreeNode> treeNodes=new ArrayList<TreeNode>();
		String hql="from Type t";
		List<Type> types=typeDao.find(hql);
		
		for (Type type : types) {
			TreeNode tNode=new TreeNode();
			if (type.getType().getTypeId()!=1) {
				tNode.setPid(type.getType().getTypeId().toString());
			}
			tNode.setId(type.getTypeId().toString());
			tNode.setText(type.getName());
			tNode.setState("open");
			treeNodes.add(tNode);
		}
		
		return treeNodes;
	}

	@Override
	public void deleteType(String typeId) {
		// TODO Auto-generated method stub
		typeDao.delete(typeDao.get(Type.class, Long.parseLong(typeId)));
	}

	@Override
	public Result editType(MType mType) {
		// TODO Auto-generated method stub
		Type tempType=typeDao.get(Type.class, mType.getTypeId());
		Result result=new Result();
		if (tempType!=null) {
			try {
				
			BeanUtils.copyProperties(mType, tempType, new String[] { "typeId" });
			tempType.setType(typeDao.get(Type.class, Long.parseLong(mType.get_parentId())));
			tempType.setAddDate(new Timestamp(System.currentTimeMillis()));
			typeDao.saveOrUpdate(tempType);
			
			result.setSuccess(true);
			result.setObj(null);
			result.setMsg("修改成功");

			} catch (Exception e) {
				// TODO: handle exception
				logger.info(e.getMessage());
			}
		} else {
			logger.info("type is null");
			result.setSuccess(false);
			result.setObj(null);
			result.setMsg("修改失败");
		}
		return result;
	}
}
