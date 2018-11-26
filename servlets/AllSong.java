

import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import org.json.simple.JSONObject;
import org.json.simple.parser.JSONParser;
import org.json.simple.parser.ParseException;

/**
 * Servlet implementation class AllSong
 */
@WebServlet("/AllSong")
public class AllSong extends HttpServlet {
	private static final long serialVersionUID = 1L;
       
    /**
     * @see HttpServlet#HttpServlet()
     */
    public AllSong() {
        super();
        // TODO Auto-generated constructor stub
    }

	/**
	 * @see HttpServlet#doGet(HttpServletRequest request, HttpServletResponse response)
	 */
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		HttpSession session = request.getSession();
		
		if(session.getAttribute("admin_id") == null) { //not logged in
			response.getWriter().print(DbHelper.errorJson("Admin not logged in").toString());
			return;
		}
		
//		if(request.getParameter("song_id") == null) {
//			response.getWriter().print("Incorrect Parameters Provided");
//			return;
//		}
		
//		int song_id = Integer.parseInt(request.getParameter("song_id"));
		
		JSONParser parser = new JSONParser();
		
		String query1 = "select * from song";
		String res1 = DbHelper.executeQueryJson(query1, 
				new DbHelper.ParamType[] {},
				new Object[] {});
		JSONObject json1 = new JSONObject();
		
		try {
			json1 = (JSONObject) parser.parse(res1);
		} catch (ParseException e) {
			e.printStackTrace();
		}
		
		response.getWriter().print(json1.toString());
	}

	/**
	 * @see HttpServlet#doPost(HttpServletRequest request, HttpServletResponse response)
	 */
	protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		// TODO Auto-generated method stub
		doGet(request, response);
	}

}
