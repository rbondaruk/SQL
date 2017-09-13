SELECT  CASE WHEN cs.ProjectID LIKE '.%'
			 THEN 'CPSS - Clarity'
			 WHEN cs.ProjectID LIKE 'P%' AND cs.Project LIKE 'CPSS%' AND cs.SOURCE = 'Clarity' 
			 THEN 'CPSS - Clarity'
			 WHEN cs.ProjectID LIKE 'PR%' AND cs.Project LIKE 'CPSS%' AND cs.SOURCE = 'Clarity' 
			 THEN 'CPSS - Clarity'
			 WHEN cs.ProjectID LIKE 'P%' AND cs.Project LIKE 'CPSS%' AND cs.SOURCE = 'MSP' 
			 THEN 'CPSS - MSP'
			 WHEN cs.ProjectID LIKE 'PR%' AND cs.Project LIKE 'CPSS%' AND cs.SOURCE = 'MSP' 
			 THEN 'CPSS - MSP'
			 ELSE 'Other - Clarity'
		END AS TYPE,
		cs.Project AS ProjectFilter
        cs.*
  FROM  (
	SELECT  'Clarity' AS SOURCE,
	        niku.Project,
			niku.projectid,
			res.resourcename,
			niku.resourceid,
			niku.slice_date,
			niku.totalhrs,
			niku.cmonth,
			niku.cyear
	  FROM  TRG_PROJECT_RESOURCES_TIME niku,
	  		TRG_PROJECT_RESOURCES res
	 WHERE  niku.resourceid = res.resourceid
	UNION ALL
	SELECT  'MSP' AS SOURCE,
	        msp.Project,
			msp.projectid,
			res.resourcename,
			msp.resourceid,
			msp.slice_date,
			msp.totalhrs,
			msp.cmonth,
			msp.cyear
	  FROM  TRG_PROJECT_RESOURCES_TIME_MSP msp
	       ,TRG_PROJECT_RESOURCES res
	 WHERE  msp.resourceid = res.resourceid
	   AND  msp.resourcename = res.resourcename
	   AND res.resourcename like '%Pfleiger%'
	    ) cs



