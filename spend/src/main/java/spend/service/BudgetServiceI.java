package spend.service;

import spend.pageModel.MBudget;
import spend.util.DataGrid;
import spend.util.Result;

public interface BudgetServiceI {
	public DataGrid dataGrid(MBudget mBudget);
	public Result addBudget(MBudget mBudget);
	public Result editBudget(MBudget mBudget);
	public Result deleteBudget(MBudget mBudget);
}
