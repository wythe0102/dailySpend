package spend.util;

import java.util.ArrayList;
import java.util.List;

public class LineCharts {

	public List<String> categories;
	public List<LineChartsData> series;
	public LineCharts(){
		categories=new ArrayList<String>();
		series=new ArrayList<LineChartsData>();
	}
	public List<String> getCategories() {
		return categories;
	}
	public void setCategories(List<String> categories) {
		this.categories = categories;
	}
	public List<LineChartsData> getSeries() {
		return series;
	}
	public void setSeries(List<LineChartsData> series) {
		this.series = series;
	}
}
