package spend.pageModel;

import java.sql.Timestamp;
import java.util.Date;

import spend.model.Users;

public class MDailyWeight {
	//datagrid参数
	private int page;
	private int rows;
	private String sort;
	private String order;
	private Long weightId;
	private String userId;
	private String userName;
	private Double weightAmount;
	private Timestamp time;
	private Date startDate;
	private Date endDate;
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
	public Long getWeightId() {
		return weightId;
	}
	public void setWeightId(Long weightId) {
		this.weightId = weightId;
	}
	public String getUserId() {
		return userId;
	}
	public void setUserId(String userId) {
		this.userId = userId;
	}
	public Double getWeightAmount() {
		return weightAmount;
	}
	public void setWeightAmount(Double weightAmount) {
		this.weightAmount = weightAmount;
	}
	public Timestamp getTime() {
		return time;
	}
	public void setTime(Timestamp time) {
		this.time = time;
	}
	public Date getStartDate() {
		return startDate;
	}
	public void setStartDate(Date startDate) {
		this.startDate = startDate;
	}
	public Date getEndDate() {
		return endDate;
	}
	public void setEndDate(Date endDate) {
		this.endDate = endDate;
	}
	public String getUserName() {
		return userName;
	}
	public void setUserName(String userName) {
		this.userName = userName;
	}

}
