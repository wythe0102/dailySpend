package spend.model;

import java.sql.Timestamp;
import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.FetchType;
import javax.persistence.GeneratedValue;
import static javax.persistence.GenerationType.IDENTITY;
import javax.persistence.Id;
import javax.persistence.JoinColumn;
import javax.persistence.ManyToOne;
import javax.persistence.Table;


/**
 * DailyWeight entity. @author MyEclipse Persistence Tools
 */
@Entity
@Table(name = "daily_weight", catalog = "spend")
public class DailyWeight implements java.io.Serializable {

	// Fields

	private Long weightId;
	private Users users;
	private Double weightAmount;
	private Timestamp time;

	// Constructors

	/** default constructor */
	public DailyWeight() {
	}

	/** full constructor */
	public DailyWeight(Users users, Double weightAmount, Timestamp time) {
		this.users = users;
		this.weightAmount = weightAmount;
		this.time = time;
	}

	// Property accessors
	@Id
	@GeneratedValue(strategy = IDENTITY)
	@Column(name = "weightId", unique = true, nullable = false)
	public Long getWeightId() {
		return this.weightId;
	}

	public void setWeightId(Long weightId) {
		this.weightId = weightId;
	}

	@ManyToOne(fetch = FetchType.LAZY)
	@JoinColumn(name = "userId")
	public Users getUsers() {
		return this.users;
	}

	public void setUsers(Users users) {
		this.users = users;
	}

	@Column(name = "weightAmount", precision = 22, scale = 0)
	public Double getWeightAmount() {
		return this.weightAmount;
	}

	public void setWeightAmount(Double weightAmount) {
		this.weightAmount = weightAmount;
	}

	@Column(name = "time", length = 19)
	public Timestamp getTime() {
		return this.time;
	}

	public void setTime(Timestamp time) {
		this.time = time;
	}

}