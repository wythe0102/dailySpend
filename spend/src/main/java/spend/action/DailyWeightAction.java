package spend.action;

import org.apache.struts2.convention.annotation.Action;
import org.apache.struts2.convention.annotation.Namespace;
import org.springframework.beans.factory.annotation.Autowired;

import spend.pageModel.MDailyWeight;
import spend.pageModel.MDailySpend;
import spend.service.DailyWeightServiceI;

import com.opensymphony.xwork2.ModelDriven;
@Namespace(value="/")
@Action(value="dailyWeightAction")
public class DailyWeightAction extends BaseAction implements ModelDriven<MDailyWeight> {

	private MDailyWeight MDailyWeight=new MDailyWeight();
	private DailyWeightServiceI dailyWeightService;
	public void datagrid(){
		super.writeJson(dailyWeightService.dataGrid(MDailyWeight));
	}
	public void addDailyWeight(){
		super.writeJson(dailyWeightService.addDailyWeight(MDailyWeight));
	}
	public void editDailyWeight(){
		super.writeJson(dailyWeightService.editDailyWeight(MDailyWeight));
	}
	public void deleteDailyWeight(){
		super.writeJson(dailyWeightService.deleteDailyWeight(MDailyWeight));
	}
	@Override
	public MDailyWeight getModel() {
		// TODO Auto-generated method stub
		return MDailyWeight;
	}
	public DailyWeightServiceI getdailyWeightService() {
		return dailyWeightService;
	}
	@Autowired
	public void setdailyWeightService(DailyWeightServiceI dailyWeightService) {
		this.dailyWeightService = dailyWeightService;
	}

}
