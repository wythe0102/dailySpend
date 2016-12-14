package spend.pageModel;

import spend.model.Type;

import java.sql.Timestamp;

public class MType extends Type {
	
	private String _parentId;
	private String iconCls;
	private String state;

	public String get_parentId() {
		return _parentId;
	}
	public void set_parentId(String _parentId) {
		this._parentId = _parentId;
	}
	public String getIconCls() {
		return iconCls;
	}
	public void setIconCls(String iconCls) {
		this.iconCls = iconCls;
	}
	public String getState() {
		return state;
	}
	public void setState(String state) {
		this.state = state;
	}
	
}
