package spend.pageModel;

import java.text.DateFormat;
import java.util.Date;

import spend.model.Type;
import spend.model.Users;

public class MDailySpend {
	//datagrid参数
	private int page;
	private int rows;
	private String sort;
	private String order;
	private String startDate;
	private String endDate;
	private String typeName;
	private String userName;
	private String[] dates;
	private String[] userIds;
	private String[] typeIds;
	private String[] amounts;
	private String[] demos;
	private String dailySpendIds;
	private String sumAmount;
	
	public String getDailySpendIds() {
		return dailySpendIds;
	}
	public void setDailySpendIds(String dailySpendIds) {
		this.dailySpendIds = dailySpendIds;
	}
	public String[] getDates() {
		return dates;
	}
	public void setDates(String[] dates) {
		this.dates = dates;
	}
	public String[] getUserIds() {
		return userIds;
	}
	public void setUserIds(String[] userIds) {
		this.userIds = userIds;
	}
	public String[] getTypeIds() {
		return typeIds;
	}
	public void setTypeIds(String[] typeIds) {
		this.typeIds = typeIds;
	}
	public String[] getAmounts() {
		return amounts;
	}
	public void setAmounts(String[] amounts) {
		this.amounts = amounts;
	}
	public String[] getDemos() {
		return demos;
	}
	public void setDemos(String[] demos) {
		this.demos = demos;
	}
	public String getTypeName() {
		return typeName;
	}
	public void setTypeName(String typeName) {
		this.typeName = typeName;
	}
	public String getUserName() {
		return userName;
	}
	public void setUserName(String userName) {
		this.userName = userName;
	}
	public String getStartDate() {
		return startDate;
	}
	public void setStartDate(String startDate) {
		this.startDate = startDate;
	}
	public String getEndDate() {
		return endDate;
	}
	public void setEndDate(String endDate) {
		this.endDate = endDate;
	}
	public int getPage() {
		return page;
	}
	public void setPage(int page) {
		this.page = page;
	}
	public int getRows() {
		return rows;
	}
	public void setRows(int rows) {
		this.rows = rows;
	}
	public String getSort() {
		return sort;
	}
	public void setSort(String sort) {
		this.sort = sort;
	}
	public String getOrder() {
		return order;
	}
	public void setOrder(String order) {
		this.order = order;
	}
	public String getSumAmount() {
		return sumAmount;
	}
	public void setSumAmount(String sumAmount) {
		this.sumAmount = sumAmount;
	}
	private Long spendDetailId;
	private String typeId;
	private String userId;
	private Double amount;
	private String demo;
	private Date date;
	private String year;
	
	public String getYear() {
		return year;
	}
	public void setYear(String year) {
		this.year = year;
	}
	public Long getSpendDetailId() {
		return spendDetailId;
	}
	public void setSpendDetailId(Long spendDetailId) {
		this.spendDetailId = spendDetailId;
	}
	public String getTypeId() {
		return typeId;
	}
	public void setTypeId(String typeId) {
		this.typeId = typeId;
	}
	public String getUserId() {
		return userId;
	}
	public void setUserId(String userId) {
		this.userId = userId;
	}
	public Double getAmount() {
		return amount;
	}
	public void setAmount(Double amount) {
		this.amount = amount;
	}
	public String getDemo() {
		return demo;
	}
	public void setDemo(String demo) {
		this.demo = demo;
	}
	public Date getDate() {
		return date;
	}
	public void setDate(Date date) {
		this.date = date;
	}
	
}
