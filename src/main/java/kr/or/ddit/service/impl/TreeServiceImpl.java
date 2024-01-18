package kr.or.ddit.service.impl;

import java.util.List;

import org.springframework.stereotype.Service;

import kr.or.ddit.mapper.OrganizationMapper;
import kr.or.ddit.service.TreeService;
import kr.or.ddit.vo.OrganizationChartVO;
import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class TreeServiceImpl implements TreeService{
	
	private final OrganizationMapper organizationMapper;
	
	@Override
	public List<OrganizationChartVO> chartList() {
		return this.organizationMapper.chartList();
	}

	@Override
	public int create(OrganizationChartVO organizationChartVO) {
		return this.organizationMapper.create(organizationChartVO);
	}

	@Override
	public int delete(String organizationCode) {
		return this.organizationMapper.delete(organizationCode);
	}

	@Override
	public OrganizationChartVO detail(String organizationCode) {
		return this.organizationMapper.detail(organizationCode);
	}

	
	
	
	
}
