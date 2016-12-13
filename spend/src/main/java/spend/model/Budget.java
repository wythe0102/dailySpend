package spend.model;

import java.sql.Timestamp;
import java.util.Date;
import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.FetchType;
import javax.persistence.GeneratedValue;
import static javax.persistence.GenerationType.IDENTITY;
import javax.persistence.Id;
import javax.persistence.JoinColumn;
import javax.persistence.ManyToOne;
import javax.persistence.Table;
import javax.persistence.Temporal;
import javax.persistence.TemporalType;

import spend.model.Type;

/**
 * Budget entity. @author MyEclipse Persistence Tools
 */
@Entity
@Table(name = "budget", catalog = "spend")
public class Budget implements java.io.Serializable {

	// Fields

	private Long budgetId;
	private Type type;
	private Date startDate;
	private Date endDate;
	private Double budgetAmount;
	private Double realAmount;
	private Double difference;
	private Timestamp lastUpdate;
	private Double realPercent;
	private String remarks;

	// Constructors

	/** default constructor */
	public Budget() {
	}

	/** full constructor */
	public Budget(Type type, Date startDate, Date endDate, Double budgetAmount, Double realAmount, Double difference, Timestamp lastUpdate, Double realPercent, String remarks) {
		this.type = type;
		this.startDate = startDate;
		this.endDate = endDate;
		this.budgetAmount = budgetAmount;
		this.realAmount = realAmount;
		this.difference = difference;
		this.lastUpdate = lastUpdate;
		this.realPercent = realPercent;
		this.remarks = remarks;
	}

	// Property accessors
	@Id
	@GeneratedValue(strategy = IDENTITY)
	@Column(name = "budgetId", unique = true, nullable = false)
	public Long getBudgetId() {
		return this.budgetId;
	}

	public void setBudgetId(Long budgetId) {
		this.budgetId = budgetId;
	}

	@ManyToOne(fetch = FetchType.LAZY)
	@JoinColumn(name = "typeId")
	public Type getType() {
		return this.type;
	}

	public void setType(Type type) {
		this.type = type;
	}

	@Temporal(TemporalType.DATE)
	@Column(name = "startDate", length = 10)
	public Date getStartDate() {
		return this.startDate;
	}

	public void setStartDate(Date startDate) {
		this.startDate = startDate;
	}

	@Temporal(TemporalType.DATE)
	@Column(name = "endDate", length = 10)
	public Date getEndDate() {
		return this.endDate;
	}

	public void setEndDate(Date endDate) {
		this.endDate = endDate;
	}

	@Column(name = "budgetAmount", precision = 18)
	public Double getBudgetAmount() {
		return this.budgetAmount;
	}

	public void setBudgetAmount(Double budgetAmount) {
		this.budgetAmount = budgetAmount;
	}

	@Column(name = "realAmount", precision = 18)
	public Double getRealAmount() {
		return this.realAmount;
	}

	public void setRealAmount(Double realAmount) {
		this.realAmount = realAmount;
	}

	@Column(name = "difference", precision = 18)
	public Double getDifference() {
		return this.difference;
	}

	public void setDifference(Double difference) {
		this.difference = difference;
	}

	@Column(name = "lastUpdate", length = 19)
	public Timestamp getLastUpdate() {
		return this.lastUpdate;
	}

	public void setLastUpdate(Timestamp lastUpdate) {
		this.lastUpdate = lastUpdate;
	}

	@Column(name = "realPercent", precision = 22, scale = 0)
	public Double getRealPercent() {
		return this.realPercent;
	}

	public void setRealPercent(Double realPercent) {
		this.realPercent = realPercent;
	}

	@Column(name = "remarks", length = 65535)
	public String getRemarks() {
		return this.remarks;
	}

	public void setRemarks(String remarks) {
		this.remarks = remarks;
	}

}