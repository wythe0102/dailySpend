package spend.action;

import org.apache.log4j.Logger;
import org.apache.struts2.convention.annotation.Action;
import org.apache.struts2.convention.annotation.Namespace;
import org.springframework.beans.factory.annotation.Autowired;

import spend.pageModel.MType;
import spend.service.TypeServiceI;

import com.opensymphony.xwork2.ModelDriven;

@Namespace(value="/")
@Action(value="typeAction")
public class TypeAction extends BaseAction implements ModelDriven<MType> {

	private static final Logger logger=Logger.getLogger(TypeAction.class);
	private TypeServiceI typeService;
	
	public void tree(){
		super.writeJson(typeService.tree());
	}
	public void delete(){
		typeService.deleteType(mtype.getTypeId().toString());
	}
	public void treegrid(){
		super.writeJson(typeService.treegrid(mtype));
	}
	
	public void addType(){
		super.writeJson(typeService.addType(mtype));
	}
	
	public void editType(){
		super.writeJson(typeService.editType(mtype));
	}
	
	public TypeServiceI getTypeService() {
		return typeService;
	}
	@Autowired
	public void setTypeService(TypeServiceI typeService) {
		this.typeService = typeService;
	}
	
	MType mtype=new MType();
	@Override
	public MType getModel() {
		// TODO Auto-generated method stub
		return mtype;
	}
	
}
