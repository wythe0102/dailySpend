package spend.service;

import spend.pageModel.MDailySpend;
import spend.util.DataGrid;
import spend.util.LineCharts;
import spend.util.Result;

public interface DailySpendI {

	public DataGrid dataGrid(MDailySpend mDailySpend);
	public DataGrid dataSumGrid(MDailySpend mDailySpend);
	public Result addDailySpend(MDailySpend mDailySpend);
	public Result editDailySpend(MDailySpend mDailySpend);
	public Result deleteDailySpend(MDailySpend mDailySpend);
	public LineCharts dataLineCharts(MDailySpend mDailySpend);
	public LineCharts dataLineChartsYear(MDailySpend mDailySpend);
}
