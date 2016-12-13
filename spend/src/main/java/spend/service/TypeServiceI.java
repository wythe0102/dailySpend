package spend.service;

import java.util.List;

import spend.pageModel.MType;
import spend.util.DataGrid;
import spend.util.Result;
import spend.util.TreeNode;

public interface TypeServiceI {

	public Result addType(MType mType);
	public DataGrid treegrid(MType mtype);
	public List<TreeNode> tree();
	public void deleteType(String typeId);
	public Result editType(MType mType);
}
