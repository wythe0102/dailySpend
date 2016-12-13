package spend.util;

import java.util.List;
import java.util.Map;

public class TreeNode {
	private String id;
	private String text;
	private String state;
	private String checked;
	private Map<String, Object> attributes;
	private List<TreeNode> children;
	private String pid;
	public TreeNode(){
		id="";
		text="";
		state="";
		checked="";
		attributes=null;
		children=null;
		pid="";
	}
	public String getId() {
		return id;
	}
	public void setId(String id) {
		this.id = id;
	}
	public String getText() {
		return text;
	}
	public void setText(String text) {
		this.text = text;
	}
	public String getState() {
		return state;
	}
	public void setState(String state) {
		this.state = state;
	}
	public String getChecked() {
		return checked;
	}
	public void setChecked(String checked) {
		this.checked = checked;
	}
	public Map<String, Object> getAttributes() {
		return attributes;
	}
	public void setAttributes(Map<String, Object> attributes) {
		this.attributes = attributes;
	}
	public String getPid() {
		return pid;
	}
	public void setPid(String pid) {
		this.pid = pid;
	}
	public List<TreeNode> getChildren() {
		return children;
	}
	public void setChildren(List<TreeNode> children) {
		this.children = children;
	}
	
}
