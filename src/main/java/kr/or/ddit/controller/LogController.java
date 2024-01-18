package kr.or.ddit.controller;

import java.util.List;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseBody;

import kr.or.ddit.service.TreeService;
import kr.or.ddit.vo.OrganizationChartVO;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;

@Controller
@Slf4j
@RequiredArgsConstructor
@RequestMapping("/tree")
public class LogController {
	
	private final TreeService treeService;
	
	// 형택이형의 절규
	@ResponseBody
	@GetMapping("/log")
	public String log() {
		log.error("제발 살려주세요");
		return "제발";
	}
	
	// 메인화면이동
	@GetMapping
	public void tree(Model model) {
		
		List<OrganizationChartVO> chartList = this.treeService.chartList();
		model.addAttribute("chartList", chartList);
		
	}
	
	// renderTree()의 ajax의 url
	@GetMapping("/list")
	@ResponseBody
	public List<OrganizationChartVO> list() {
		List<OrganizationChartVO> chartList = this.treeService.chartList();
		log.info("chartList => {}", chartList);
		return chartList;
	}
	
	@PostMapping("/create")
	@ResponseBody
	public int create(@RequestBody OrganizationChartVO organizationChartVO) {
		
		log.info("vo => {}", organizationChartVO);
		
		int cnt = this.treeService.create(organizationChartVO);
		return cnt;
	}
	
	@GetMapping("/{nodeName}")
	public String create(@PathVariable String nodeName, Model model) {
		model.addAttribute("nodeName", nodeName);
		return "tree";
	}
	
	@PostMapping("/delete")
	@ResponseBody
	public int delete(@RequestBody List<OrganizationChartVO> chartList) {
		log.info("chartList ==> {}", chartList);
		int result = 0;
		for (OrganizationChartVO chart : chartList) {
			result += this.treeService.delete(chart.getOrganizationCode());
		}
		
		return result;
	}
	
	// 노드가 선택될 때 ajax방식으로 db에서 해당 노드에 대한 상세정보를 가져옴 
	@GetMapping("/detail")
	@ResponseBody
	public OrganizationChartVO detail(String organizationCode, Model model) {
		OrganizationChartVO chart = this.treeService.detail(organizationCode);
		return chart;
	}
	
	@PostMapping("/detail")
	public String detail(OrganizationChartVO organizationVO) {
		return "null";
	}
}
