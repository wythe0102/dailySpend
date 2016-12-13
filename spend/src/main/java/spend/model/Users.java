package spend.model;

import java.util.Date;
import java.util.HashSet;
import java.util.Set;
import javax.persistence.CascadeType;
import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.FetchType;
import javax.persistence.GeneratedValue;
import static javax.persistence.GenerationType.IDENTITY;
import javax.persistence.Id;
import javax.persistence.OneToMany;
import javax.persistence.Table;
import javax.persistence.Temporal;
import javax.persistence.TemporalType;

/**
 * Users entity. @author MyEclipse Persistence Tools
 */
@Entity
@Table(name = "users", catalog = "spend")
public class Users implements java.io.Serializable {

	// Fields

	private Long userId;
	private String name;
	private String username;
	private String password;
	private String sex;
	private String demo;
	private Date birthday;
	private String idNum;
	private Set<DailySpend> dailySpends = new HashSet<DailySpend>(0);

	// Constructors

	/** default constructor */
	public Users() {
	}

	/** full constructor */
	public Users(String name, String username, String password, String sex, String demo, Date birthday, String idNum, Set<DailySpend> dailySpends) {
		this.name = name;
		this.username = username;
		this.password = password;
		this.sex = sex;
		this.demo = demo;
		this.birthday = birthday;
		this.idNum = idNum;
		this.dailySpends = dailySpends;
	}

	// Property accessors
	@Id
	@GeneratedValue(strategy = IDENTITY)
	@Column(name = "userId", unique = true, nullable = false)
	public Long getUserId() {
		return this.userId;
	}

	public void setUserId(Long userId) {
		this.userId = userId;
	}

	@Column(name = "name", length = 40)
	public String getName() {
		return this.name;
	}

	public void setName(String name) {
		this.name = name;
	}

	@Column(name = "username", length = 40)
	public String getUsername() {
		return this.username;
	}

	public void setUsername(String username) {
		this.username = username;
	}

	@Column(name = "password", length = 400)
	public String getPassword() {
		return this.password;
	}

	public void setPassword(String password) {
		this.password = password;
	}

	@Column(name = "sex", length = 10)
	public String getSex() {
		return this.sex;
	}

	public void setSex(String sex) {
		this.sex = sex;
	}

	@Column(name = "demo", length = 20000)
	public String getDemo() {
		return this.demo;
	}

	public void setDemo(String demo) {
		this.demo = demo;
	}

	@Temporal(TemporalType.DATE)
	@Column(name = "birthday", length = 10)
	public Date getBirthday() {
		return this.birthday;
	}

	public void setBirthday(Date birthday) {
		this.birthday = birthday;
	}

	@Column(name = "IdNum", length = 40)
	public String getIdNum() {
		return this.idNum;
	}

	public void setIdNum(String idNum) {
		this.idNum = idNum;
	}

	@OneToMany(cascade = CascadeType.ALL, fetch = FetchType.LAZY, mappedBy = "users")
	public Set<DailySpend> getDailySpends() {
		return this.dailySpends;
	}

	public void setDailySpends(Set<DailySpend> dailySpends) {
		this.dailySpends = dailySpends;
	}

}