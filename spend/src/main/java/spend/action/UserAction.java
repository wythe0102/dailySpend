package spend.action;

import org.apache.struts2.convention.annotation.Action;
import org.apache.struts2.convention.annotation.Namespace;
import org.springframework.beans.factory.annotation.Autowired;

import spend.pageModel.MUser;
import spend.service.UserServiceI;

import com.opensymphony.xwork2.ModelDriven;
import com.sun.org.apache.bcel.internal.generic.NEW;

@Namespace(value="/")
@Action(value="userAction")
public class UserAction extends BaseAction implements ModelDriven<MUser> {

	private UserServiceI userService;
	public void combobox(){
		super.writeJson(userService.combobox());
	}
	public UserServiceI getUserService() {
		return userService;
	}
	@Autowired
	public void setUserService(UserServiceI userService) {
		this.userService = userService;
	}
	MUser mUser=new MUser();
	@Override
	public MUser getModel() {
		// TODO Auto-generated method stub
		return mUser;
	}

}
