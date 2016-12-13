package spend.service;

import spend.pageModel.MDailyWeight;
import spend.util.DataGrid;
import spend.util.Result;

public interface DailyWeightServiceI {
	public DataGrid dataGrid(MDailyWeight mDailyWeight);
	public Result addDailyWeight(MDailyWeight mDailyWeight);
	public Result editDailyWeight(MDailyWeight mDailyWeight);
	public Result deleteDailyWeight(MDailyWeight mDailyWeight);
}
