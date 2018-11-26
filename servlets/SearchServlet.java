
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
 * Servlet implementation class SearchServlet
 */
@WebServlet("/SearchServlet")
public class SearchServlet extends HttpServlet {
	private static final long serialVersionUID = 1L;
       
    /**
     * @see HttpServlet#HttpServlet()
     */
    public SearchServlet() {
        super();
        // TODO Auto-generated constructor stub
    }

	/**
	 * @see HttpServlet#doGet(HttpServletRequest request, HttpServletResponse response)
	 */
    @SuppressWarnings("unchecked")
	protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		HttpSession session = request.getSession();
		
		if(session.getAttribute("user_id") == null) { //not logged in
			response.getWriter().print(DbHelper.errorJson("Not logged in").toString());
			return;
		}
		
		if(request.getParameter("search_key") == null) {
			response.getWriter().print("Incorrect Parameters Provided");
			return;
		}
				
		String search_key = request.getParameter("search_key").toString();
		JSONParser parser = new JSONParser();
		// create extension pg_trgm;

		String query1 = "(select song_id, name from song order by word_similarity(name, ?) desc limit 5)"
				+ " UNION (select song_id, name from song order by word_similarity(lyrics_link, ?) desc limit 3)";
		String res1 = DbHelper.executeQueryJson(query1, 
				new DbHelper.ParamType[] {DbHelper.ParamType.STRING, DbHelper.ParamType.STRING},
				new Object[] {search_key, search_key});
		JSONObject json1 = new JSONObject();
		try {
			json1 = (JSONObject) parser.parse(res1);
		} catch (ParseException e) {
			e.printStackTrace();
		}
		
		String query2 = "select album_id, name from album order by word_similarity(name, ?) desc limit 5";
		String res2 = DbHelper.executeQueryJson(query2, 
				new DbHelper.ParamType[] {DbHelper.ParamType.STRING},
				new Object[] {search_key});
		JSONObject json2 = new JSONObject();
		try {
			json2 = (JSONObject) parser.parse(res2);
		} catch (ParseException e) {
			e.printStackTrace();
		}
		
		String query3 = "select artist_id, name from artist order by word_similarity(name, ?) desc limit 5";
		String res3 = DbHelper.executeQueryJson(query3, 
				new DbHelper.ParamType[] {DbHelper.ParamType.STRING},
				new Object[] {search_key});
		JSONObject json3 = new JSONObject();
		try {
			json3 = (JSONObject) parser.parse(res3);
		} catch (ParseException e) {
			e.printStackTrace();
		}
		
		JSONObject ret = new JSONObject();
		ret.put("songs", json1);
		ret.put("albums", json2);
		ret.put("artists" , json3);
		response.getWriter().print(ret.toString());
		
	}

	/**
	 * @see HttpServlet#doPost(HttpServletRequest request, HttpServletResponse response)
	 */
	protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		doGet(request, response);
	}


}
