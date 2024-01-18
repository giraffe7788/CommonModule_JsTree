package kr.or.ddit.mapper;

import java.util.List;

import kr.or.ddit.vo.OrganizationChartVO;

public interface OrganizationMapper {

	public List<OrganizationChartVO> chartList();

	public int create(OrganizationChartVO organizationChartVO);

	public int delete(String organizationCode);

	public OrganizationChartVO detail(String organizationCode);
	
	
}
