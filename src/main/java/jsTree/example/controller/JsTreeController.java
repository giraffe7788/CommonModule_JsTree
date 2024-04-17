package jsTree.example.controller;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;

@Controller
@RequestMapping("/jstree")
public class JsTreeController {

	/**
	 * 메인 페이지 이동
	 */
	@GetMapping("/main")
	public String main() {
		return "jsTree";
	}
}
