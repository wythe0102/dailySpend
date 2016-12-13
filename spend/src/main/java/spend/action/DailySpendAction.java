package spend.action;

import org.apache.struts2.convention.annotation.Action;
import org.apache.struts2.convention.annotation.Namespace;
import org.springframework.beans.factory.annotation.Autowired;

import spend.pageModel.MDailySpend;
import spend.service.DailySpendI;

import com.opensymphony.xwork2.ModelDriven;

@Namespace(value="/")
@Action(value="dailySpendAction")
public class DailySpendAction extends BaseAction implements ModelDriven<MDailySpend> {

	private DailySpendI dailySpendService;
	MDailySpend mDailySpend=new MDailySpend();
	
	public void datagrid(){
		super.writeJson(dailySpendService.dataGrid(mDailySpend));
	}
	
	public void dataSumGrid(){
		super.writeJson(dailySpendService.dataSumGrid(mDailySpend));
	}
	
	public void dataLineCharts(){
		super.writeJson(dailySpendService.dataLineCharts(mDailySpend));
	}
	
	public void dataLineChartsYear(){
		super.writeJson(dailySpendService.dataLineChartsYear(mDailySpend));
	}
	
	public void addDailySpend(){
		super.writeJson(dailySpendService.addDailySpend(mDailySpend));
	}
	
	public void editDailySpend(){
		super.writeJson(dailySpendService.editDailySpend(mDailySpend));
	}
	
	public void delete(){
		super.writeJson(dailySpendService.deleteDailySpend(mDailySpend));
	}
	
	@Override
	public MDailySpend getModel() {
		// TODO Auto-generated method stub
		return mDailySpend;
	}
	public DailySpendI getDailySpendService() {
		return dailySpendService;
	}
	@Autowired
	public void setDailySpendService(DailySpendI dailySpendService) {
		this.dailySpendService = dailySpendService;
	}
}
