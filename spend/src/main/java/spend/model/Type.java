package spend.model;

import java.sql.Timestamp;
import java.util.HashSet;
import java.util.Set;
import javax.persistence.CascadeType;
import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.FetchType;
import javax.persistence.GeneratedValue;
import static javax.persistence.GenerationType.IDENTITY;
import javax.persistence.Id;
import javax.persistence.JoinColumn;
import javax.persistence.ManyToOne;
import javax.persistence.OneToMany;
import javax.persistence.Table;

/**
 * Type entity. @author MyEclipse Persistence Tools
 */
@Entity
@Table(name = "type", catalog = "spend")
public class Type implements java.io.Serializable {

	// Fields
	private Long typeId;
	private Type type;
	private String name;
	private String code;
	private Timestamp addDate;
	private Set<Type> types = new HashSet<Type>(0);
	private Set<DailySpend> dailySpends = new HashSet<DailySpend>(0);

	// Constructors

	/** default constructor */
	public Type() {
	}

	/** full constructor */
	public Type(Type type, String name, String code, Timestamp addDate, Set<Type> types, Set<DailySpend> dailySpends) {
		this.type = type;
		this.name = name;
		this.code = code;
		this.addDate = addDate;
		this.types = types;
		this.dailySpends = dailySpends;
	}

	// Property accessors
	@Id
	@GeneratedValue(strategy = IDENTITY)
	@Column(name = "typeId", unique = true, nullable = false)
	public Long getTypeId() {
		return this.typeId;
	}

	public void setTypeId(Long typeId) {
		this.typeId = typeId;
	}

	@ManyToOne(fetch = FetchType.LAZY)
	@JoinColumn(name = "parentId")
	public Type getType() {
		return this.type;
	}

	public void setType(Type type) {
		this.type = type;
	}

	@Column(name = "name", length = 200)
	public String getName() {
		return this.name;
	}

	public void setName(String name) {
		this.name = name;
	}

	@Column(name = "code", length = 40)
	public String getCode() {
		return this.code;
	}

	public void setCode(String code) {
		this.code = code;
	}

	@Column(name = "addDate", length = 19)
	public Timestamp getAddDate() {
		return this.addDate;
	}

	public void setAddDate(Timestamp addDate) {
		this.addDate = addDate;
	}

	@OneToMany(cascade = CascadeType.ALL, fetch = FetchType.LAZY, mappedBy = "type")
	public Set<Type> getTypes() {
		return this.types;
	}

	public void setTypes(Set<Type> types) {
		this.types = types;
	}

	@OneToMany(cascade = CascadeType.ALL, fetch = FetchType.LAZY, mappedBy = "type")
	public Set<DailySpend> getDailySpends() {
		return this.dailySpends;
	}

	public void setDailySpends(Set<DailySpend> dailySpends) {
		this.dailySpends = dailySpends;
	}

}