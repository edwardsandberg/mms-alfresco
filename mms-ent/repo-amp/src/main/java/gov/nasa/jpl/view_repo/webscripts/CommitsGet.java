package gov.nasa.jpl.view_repo.webscripts;

import gov.nasa.jpl.mbee.util.Timer;
import gov.nasa.jpl.mbee.util.Utils;
import gov.nasa.jpl.view_repo.db.ElasticHelper;
import gov.nasa.jpl.view_repo.util.EmsNodeUtil;
import gov.nasa.jpl.view_repo.util.LogUtil;
import org.alfresco.repo.model.Repository;
import org.alfresco.repo.security.authentication.AuthenticationUtil;
import org.alfresco.service.ServiceRegistry;
import org.apache.log4j.Level;
import org.apache.log4j.Logger;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;
import org.springframework.extensions.webscripts.Cache;
import org.springframework.extensions.webscripts.Status;
import org.springframework.extensions.webscripts.WebScriptRequest;

import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.HashMap;
import java.util.Map;

import static gov.nasa.jpl.view_repo.util.Sjm.COMMITID;


/**
 * @author dank
 *
 */
public class CommitsGet extends AbstractJavaWebScript {

    static Logger logger = Logger.getLogger(HistoryGet.class);

    /**
     *
     */
    public CommitsGet() {
        super();
    }

    /**
     *
     * @param repositoryHelper
     * @param registry
     */
    public CommitsGet(Repository repositoryHelper, ServiceRegistry registry) {
        super(repositoryHelper, registry);
    }

    @Override
    protected Map<String, Object> executeImpl(WebScriptRequest req, Status status, Cache cache) {
        CommitsGet instance = new CommitsGet(repository, getServices());
        return instance.executeImplImpl(req, status, cache);
    }


    @Override
    protected Map<String, Object> executeImplImpl(WebScriptRequest req, Status status, Cache cache) {
        String user = AuthenticationUtil.getFullyAuthenticatedUser();
        printHeader(user, logger, req);
        Timer timer = new Timer();

        Map<String, Object> model = new HashMap<>();
        JSONObject top = new JSONObject();
        JSONArray elementJson = null;

        if (logger.isDebugEnabled()) {
            logger.debug(user + " " + req.getURL());
        }

        try {
            if (validateRequest(req, status)) {
                String projectId = getProjectId(req);

                elementJson = handleRequest(req, projectId);

            }
        } catch (JSONException e) {
            log(Level.ERROR, HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "JSON could not be created\n");
            logger.error(String.format("%s", LogUtil.getStackTrace(e)));
        } catch (Exception e) {
            log(Level.ERROR, HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Internal error stack trace:\n %s \n",
                e.getLocalizedMessage());
            logger.error(String.format("%s", LogUtil.getStackTrace(e)));
        }

        try {
            if (elementJson.length() > 0) {
                top.put("commits", elementJson);
            } else {
                responseStatus.setCode(HttpServletResponse.SC_NOT_FOUND);
            }

            if (!Utils.isNullOrEmpty(response.toString()))
                top.put("message", response.toString());

        } catch (JSONException e) {
            log(Level.ERROR, HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Could not create JSONObject");
            logger.warn(String.format("%s", LogUtil.getStackTrace(e)));
        }

        status.setCode(responseStatus.getCode());
        model.put("res", top.toString(4));

        printFooter(user, logger, timer);
        return model;
    }

    /**
     * Validate the request and check some permissions
     */
    @Override protected boolean validateRequest(WebScriptRequest req, Status status) {
        String id = req.getServiceMatch().getTemplateVars().get(REF_ID);
        return checkRequestContent(req) && checkRequestVariable(id, REF_ID);
    }

    /**
     * Wrapper for handling a request and getting the appropriate Commit JSONObject
     *
     * @param req
     * @return
     */
    private JSONArray handleRequest(WebScriptRequest req, String projectId) {

        EmsNodeUtil emsNodeUtil = new EmsNodeUtil(projectId, "master");
        JSONArray commitJson = new JSONArray();
        String commitId = req.getServiceMatch().getTemplateVars().get(COMMIT_ID);

        if (commitId == null){
            logger.error("Did not find commit");
            return commitJson;
        }
        logger.info("Commit ID " + commitId + " found");

        try {
            ElasticHelper eh = new ElasticHelper();
            commitJson.put(emsNodeUtil.getCommitObject(commitId));
        } catch (IOException e) {
            log(Level.ERROR, HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Could not insert into ElasticSearch");
            logger.warn(String.format("%s", LogUtil.getStackTrace(e)));
        }

        return commitJson;
    }
}

