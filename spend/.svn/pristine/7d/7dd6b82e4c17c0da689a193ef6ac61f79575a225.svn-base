package spend.service.impl;

import java.util.ArrayList;
import java.util.List;

import org.apache.log4j.Logger;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import spend.dao.BaseDaoI;
import spend.model.Users;
import spend.service.UserServiceI;
import spend.util.Combobox;

@Service(value="userService")
public class UserServiceImpl implements UserServiceI {
	
	private static Logger logger=Logger.getLogger(UserServiceImpl.class);
	private BaseDaoI<Users> userDao;
	
	@Override
	public List<Combobox> combobox() {
		// TODO Auto-generated method stub
		List<Combobox> comboboxs=new ArrayList<Combobox>();
		String hql="from Users u";
		List<Users> users=userDao.find(hql);
		if (users!=null && users.size()>0) {
			for (Users tempUser : users) {
				Combobox tCombobox=new Combobox();
				tCombobox.setId(tempUser.getUserId().toString());
				tCombobox.setText(tempUser.getName());
				comboboxs.add(tCombobox);
			}
		}	
		return comboboxs;
	}

	public BaseDaoI<Users> getUserDao() {
		return userDao;
	}
	@Autowired
	public void setUserDao(BaseDaoI<Users> userDao) {
		this.userDao = userDao;
	}

}
