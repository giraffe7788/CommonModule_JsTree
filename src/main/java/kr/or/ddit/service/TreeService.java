package kr.or.ddit.service;

import java.util.List;

import kr.or.ddit.vo.OrganizationChartVO;

public interface TreeService {
	
	public List<OrganizationChartVO> chartList();

	public int create(OrganizationChartVO organizationChartVO);

	public int delete(String organizationCode);

	public OrganizationChartVO detail(String organizationCode);

	
}
