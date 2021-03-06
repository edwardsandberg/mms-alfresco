*** Settings ***
Documentation	Testing branches and commits
Resource		../resources.robot

*** Test Cases ***

GetCommitHistoryFromPAOnMasterC0
	[Documentation]		"check get element using commit 0 on master"
	[Tags]				branches		critical		090201
	${result} =			Get	url=${ROOT}/projects/PA/refs/master/elements/test_history_element?commitId=${commit0}		headers=&{REQ_HEADER}
	Should Be Equal		${result.status_code}		${200}
	${filter} =			Create List	 _commitId		nodeRefId		 versionedRefId		 _created		 read		 lastModified		 _modified		 siteCharacterizationId		 time_total		 _elasticId		 _timestamp		 _inRefIds		 id
	Generate JSON		${TEST_NAME}		${result.json()}		${filter}
	${compare_result} =		Compare JSON		${TEST_NAME}
	Should Match Baseline		${compare_result}

GetCommitHistoryFromPAOnMasterC2
	[Documentation]		"get element using commit 2 on master"
	[Tags]				branches		critical		090202
	${result} =			Get	url=${ROOT}/projects/PA/refs/master/elements/test_history_element?commitId=${commit2}		headers=&{REQ_HEADER}
	Should Be Equal		${result.status_code}		${200}
	${filter} =			Create List	 _commitId		nodeRefId		 versionedRefId		 _created		 read		 lastModified		 _modified		 siteCharacterizationId		 time_total		 _elasticId		 _timestamp		 _inRefIds		 id
	Generate JSON		${TEST_NAME}		${result.json()}		${filter}
	${compare_result} =		Compare JSON		${TEST_NAME}
	Should Match Baseline		${compare_result}

GetCommitHistoryFromPAOnNewBranchC0
	[Documentation]		"get element using commit 0 on new branch"
	[Tags]				branches		critical		090203
	${result} =			Get	url=${ROOT}/projects/PA/refs/newbranch/elements/test_history_element?commitId=${commit0}		headers=&{REQ_HEADER}
	Should Be Equal		${result.status_code}		${200}
	${filter} =			Create List	 _commitId		nodeRefId		 versionedRefId		 _created		 read		 lastModified		 _modified		 siteCharacterizationId		 time_total		 _elasticId		 _timestamp		 _inRefIds		 id
	Generate JSON		${TEST_NAME}		${result.json()}		${filter}
	${compare_result} =		Compare JSON		${TEST_NAME}
	Should Match Baseline		${compare_result}

GetCommitHistoryFromPAOnNewBranchC3
	[Documentation]		"get element using commit 3 on new branch"
	[Tags]				branches		critical		090204
	${result} =			Get	url=${ROOT}/projects/PA/refs/newbranch/elements/test_history_element?commitId=${commit3}		headers=&{REQ_HEADER}
	Should Be Equal		${result.status_code}		${200}
	${filter} =			Create List	 _commitId		nodeRefId		 versionedRefId		 _created		 read		 lastModified		 _modified		 siteCharacterizationId		 time_total		 _elasticId		 _timestamp		 _inRefIds		 id
	Generate JSON		${TEST_NAME}		${result.json()}		${filter}
	${compare_result} =		Compare JSON		${TEST_NAME}
	Should Match Baseline		${compare_result}

GetElementAtCommit
	[Documentation]		"Gets an element at a commit -- Should return element"
	[Tags]				branches		critical		090205
	${element} =		Get	url=${ROOT}/projects/PA/refs/master/elements/300		headers=&{REQ_HEADER}
	${commitId} =		Get Commit From Json		${element.json()}
	${result} =			Get	url=${ROOT}/projects/PA/refs/master/elements/300?commitId=${commitId}		headers=&{REQ_HEADER}
	Should Be Equal		${result.status_code}		${200}
	Should Be Equal		${result.json()["elements"][0]["id"]}		${element.json()["elements"][0]["id"]}
	Should Be Equal		${result.json()["elements"][0]["_commitId"]}		${element.json()["elements"][0]["_commitId"]}
	Should Be Equal		${result.json()["elements"][0]["_modified"]}		${element.json()["elements"][0]["_modified"]}

GetElementBeforeCommit
    [Documentation]     "Gets an element that exists before the commit. Grabs a commit that does not contain the element and requests for the element at that time. It should return the element at a previous commit than the one requested."
	[Tags]				branches		critical		090206
    ${element} =        Get    url=${ROOT}/projects/PA/refs/master/elements/300         headers=&{REQ_HEADER}
	${post_json} =		Get File	    ${CURDIR}/../../JsonData/UpdateElementToGetElementBeforeCommit.json
    ${result} =         Post    url=${ROOT}/projects/PA/refs/master/elements      data=${post_json}           headers=&{REQ_HEADER}
    Sleep               2s
    ${commitId} =       Set Variable        ${result.json()["elements"][0]["_commitId"]}
    ${result} =         Get     url=${ROOT}/projects/PA/refs/master/elements/300?commitId=${commitId}       headers=&{REQ_HEADER}
    Should Be Equal     ${result.status_code}       ${200}
    # Tests to see that the element is infact the element at a different point, also verifies that the element is not the same element at the commit
    Should Be Equal     ${result.json()["elements"][0]["_commitId"]}        ${element.json()["elements"][0]["_commitId"]}
	${filter} =			Create List     _commitId		nodeRefId		 versionedRefId		 _created		 read		 lastModified		 _modified		 siteCharacterizationId		 time_total		 _elasticId		 _timestamp		 _inRefIds		 id
	Generate JSON		${TEST_NAME}		${result.json()}		${filter}
	${compare_result} =	Compare JSON		${TEST_NAME}
	Should Match Baseline		${compare_result}

GetElementAfterCommit
	[Documentation]		"Get an element that doesn't exist at the current commit. Should return a 404"
	[Tags]				branches		critical		090207
	${post_json} =		Get File		${CURDIR}/../../JsonData/CreateElementAfterCommit.json
	${result} =			Post	url=${ROOT}/projects/PA/refs/master/elements	 data=${post_json}		headers=&{REQ_HEADER}
	Sleep				${2}
	# Grab an element with an older commitId
	${element} =		Get	url=${ROOT}/projects/PA/refs/master/elements/300		 headers=&{REQ_HEADER}
	${result} =			Get	url=${ROOT}/projects/PA/refs/master/elements/ElementAfterCommit?commitId=${element.json()["elements"][0]["_commitId"]}	   headers=&{REQ_HEADER}
	Should be Equal		${result.status_code}		${404}

GetElementAtInvalidCommit
	[Documentation]		"Try to get an element at an invalid commit."
	[Tags]				branches		critical		090208
	${result} =			Get	url=${ROOT}/projects/PA/refs/master/elements/300?commitId=ThisIdShouldNotExistAtAll		 headers=&{REQ_HEADER}
	Should be Equal		${result.status_code}	   ${400}

BranchFromBranchAndCheckCommits
	[Documentation]		"Create branch1, create branch 2 immediately from branch 1, getting branch history from branch 1 and branch 2 should be the same."
	[Tags]				branches		critical		090209
	${post_json} =		Get File		${CURDIR}/../../JsonData/PostBranch1FromMaster.json
	${branch_1_json} =	Post		url=${ROOT}/projects/PA/refs		data=${post_json}		headers=&{REQ_HEADER}
	Should Be Equal		${branch_1_json.status_code}		${200}
	Sleep				${POST_DELAY_INDEXING}
	${post_json} =		Get File		${CURDIR}/../../JsonData/PostBranch2FromBranch1.json
	${branch_2_json} =	Post		url=${ROOT}/projects/PA/refs		data=${post_json}		headers=&{REQ_HEADER}
	Should Be Equal		${branch_2_json.status_code}		${200}
	Sleep				${BRANCH_DELAY_INDEXING}
	${branch_1_json} =	Get		 url=${ROOT}/projects/PA/refs/pa_branch_1/history
	${branch_2_json} =	Get		 url=${ROOT}/projects/PA/refs/pa_branch_2/history
	${result} =			Compare Json To Json		${branch_2_json.json()}		${branch_1_json.json()}
	Should be true		${result}

BranchFromThePastAndCheckCommits
	[Documentation]		"Create branch from branch in the past then check if the number of commits stayed the same."
	[Tags]				branches		critical		090210
	${branch_1_history} =	Get		 url=${ROOT}/projects/PA/refs/pa_branch_1/history
	${commit_num} =     Get Number Of commits   PA
	${commitId} =       Set Variable        ${branch_1_history.json()["commits"][4]["id"]}
	${post_json} =		Get File		${CURDIR}/../../JsonData/PostBranchFromPast.json
	${branch_1_json} =	Post		url=${ROOT}/projects/PA/refs?commitId=${commitId}		data=${post_json}		headers=&{REQ_HEADER}
	Should Be Equal		${branch_1_json.status_code}		${200}
	Sleep				${BRANCH_DELAY_INDEXING}
	${branch_history} =	    Get number of commits      PA
	Should Be Equal     ${branch_history}       ${commit_num}

GetCommitObject
    [Documentation]     "Get a commit object"
    [Tags]              commits         critical        090211
    ${branch_1_history} =	Get		 url=${ROOT}/projects/PA/refs/master/history
    ${num_commits} =        Get Number of Commits       PA
    ${commitId} =       Set Variable        ${branch_1_history.json()["commits"][${num_commits} - 1]["id"]}
    ${result} =         Get     url=${ROOT}/projects/PA/commits/${commitId}
    Should Be Equal     ${result.status_code}           ${200}
	${filter} =			Create List     _commitId		nodeRefId		 versionedRefId		 _created		 read		 lastModified		 _modified		 siteCharacterizationId		 time_total		 _elasticId		 _timestamp		 _inRefIds		 id		 _projectId
	Generate JSON		${TEST_NAME}		${result.json()}		${filter}
    ${compare_result} =	Compare JSON		${TEST_NAME}
	Should Match Baseline		${compare_result}

GetElementAtCommitBetweenDeletionAndResurrection
    [Documentation]     "Get an element at a commit that is in between the element being deleted and resurrected."
    [Tags]              commits         critical        090212
    # Make sure the delete element exists, then delete it
    ${post_json} =      Get File        ${CURDIR}/../../JsonData/DeleteResurrectElements.json
    ${result} =         Post            url=${ROOT}/projects/PA/refs/master/elements        data=${post_json}       headers=&{REQ_HEADER}
	Should Be Equal		${result.status_code}		${200}
	Sleep				${POST_DELAY_INDEXING}
	${result} =         Delete          url=${ROOT}/projects/PA/refs/master/elements/DeleteResurrectElement          headers=&{REQ_HEADER}
	Should Be Equal		${result.status_code}		${200}
	# Update another element to create new commit
    ${post_json} =      Get File        ${CURDIR}/../../JsonData/UpdateRandomElement.json
    ${result} =         Post            url=${ROOT}/projects/PA/refs/master/elements        data=${post_json}       headers=&{REQ_HEADER}
	Should Be Equal		${result.status_code}		${200}
	Sleep				${POST_DELAY_INDEXING}
	# Get commit Id
	${commit_id} =      Set Variable        ${result.json()["elements"][0]["_commitId"]}
	# Resurrect the element
    ${post_json} =      Get File        ${CURDIR}/../../JsonData/ResurrectDeleteElement.json
    ${result} =         Post            url=${ROOT}/projects/PA/refs/master/elements        data=${post_json}       headers=&{REQ_HEADER}
	Should Be Equal		${result.status_code}		${200}
	Sleep				${POST_DELAY_INDEXING}
	# Get element at the commit and it should be deleted
	${result} =         Get             url=${ROOT}/projects/PA/refs/master/elements/DeleteResurrectElement?commitId=${commit_id}
	Should Be Equal		${result.status_code}		${410}
	${filter} =			Create List     _commitId		nodeRefId		 versionedRefId		 _created		 read		 lastModified		 _modified		 siteCharacterizationId		 time_total		 _elasticId		 _timestamp		 _inRefIds		 id
	Generate JSON		${TEST_NAME}		${result.json()}		${filter}
    ${compare_result} =	Compare JSON		${TEST_NAME}
	Should Match Baseline		${compare_result}

