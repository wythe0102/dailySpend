package spend.action;

import org.apache.struts2.convention.annotation.Action;
import org.apache.struts2.convention.annotation.Namespace;
import org.springframework.beans.factory.annotation.Autowired;

import spend.pageModel.MBudget;
import spend.pageModel.MDailySpend;
import spend.service.BudgetServiceI;

import com.opensymphony.xwork2.ModelDriven;
@Namespace(value="/")
@Action(value="budgetAction")
public class BudgetAction extends BaseAction implements ModelDriven<MBudget> {

	private MBudget mBudget=new MBudget();
	private BudgetServiceI budgetService;
	public void datagrid(){
		super.writeJson(budgetService.dataGrid(mBudget));
	}
	public void addBudget(){
		super.writeJson(budgetService.addBudget(mBudget));
	}
	public void editBudget(){
		super.writeJson(budgetService.editBudget(mBudget));
	}
	public void deleteBudget(){
		super.writeJson(budgetService.deleteBudget(mBudget));
	}
	@Override
	public MBudget getModel() {
		// TODO Auto-generated method stub
		return mBudget;
	}
	public BudgetServiceI getBudgetService() {
		return budgetService;
	}
	@Autowired
	public void setBudgetService(BudgetServiceI budgetService) {
		this.budgetService = budgetService;
	}

}
