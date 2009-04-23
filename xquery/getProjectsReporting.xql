xquery version "1.0";
(:	getProjectsReporting.xql: XQuery to return reports from the projects

		Parameters:	
			siteId = the three letter site acronym 
			id = (optional) the project id
			sortBy = default title, other values id, surname
			startYear = the earlier date boundary
			endYear = the later date boundary
			recipient = the recipient of the report
			xslt = the xslt styelsheet reference to include (not implemented)
			
		Usage Notes:
		
		Attribution:
       Author: Sven Böhm <bohms@lternet.edu>
       Date: 23-Apr-2009
       Revision: 0.1
	
		License:
        This program is free software; you can redistribute it and/or modify
        it under the terms of the GNU General Public License as published by
        the Free Software Foundation; either version 2 of the License, or
        (at your option) any later version.
    
        This program is distributed in the hope that it will be useful,
        but WITHOUT ANY WARRANTY; without even the implied warranty of
        MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
        GNU General Public License for more details (Free Software Foundation, Inc., 
        59 Temple Place, Suite 330, Boston, MA  02111-1307  USA)
:)

declare namespace eml="eml://ecoinformatics.org/project-2.1.0";

declare option exist:serialize "method=xhtml media-type=text/html";

declare function local:yearDate($datestring as xs:string) 
	as xs:gYear {
	    xs:gYear(substring($datestring, 1, 4))};


(: return true if the project is in the current date interval or if the id matches :)
	declare function local:currentProject($project, $id, $start_date as xs:string, $end_date as xs:string) 
		as xs:boolean {
	if ($id = '') then
		(($project/coverage/temporalCoverage/rangeOfDates/beginDate >= $start_date)
		and ($project/coverage/temporalCoverage/rangeOfDates/endDate <= $end_date)) 
		or $project/coverage/temporalCoverage/ongoing
		or (($project/coverage/temporalCoverage/singleDateTime/calendarDate >= $start_date) 
		and ($project/coverage/temporalCoverage/singleDateTime/calendarDate <= $end_date))
	else   
		($project/@id = $id)	};


let $site := request:get-parameter("siteId",'')
let $xslt := request:get-parameter("xlst",'')
let $id := request:get-parameter('id', '')
let $recipient := request:get-parameter('recipient','')
let $sortBy := request:get-parameter('sortBy', 'title')
let $min_date := request:get-parameter('startYear', '') cast as xs:string
let $max_date := request:get-parameter('endYear', '') cast as xs:string

(: TODO: check that values are legal :)


for $projects in collection(concat('/db/projects/',lower-case($site)))/*:researchProject/reporting[@recipient = $recipient]
		where local:currentProject($projects, $id, $min_date, $max_date)
order by $sortBy
return
<projects>{
	<project id="{$projects/@id}">
			<title>{$projects/title/text()}</title>
			{for $creators in $projects/creator
			let $individual := $creators/individualName
			let $userid := $creators/userId
			return
			<creator>{$individual}{$userid}</creator>}
			{for $people in $projects/associatedParty
			let $person_name := $people/individualName
			let $person_id := $people/userId
			let $role := $people/role
			return
			<associatedParty>{$person_name}{$person_id}{$role}</associatedParty>}
			<keywordSet>{for $keywords in $projects/keywordSet/keyword
			let $keyword := $keywords/text()
			return
			<keyword>{$keyword}</keyword>}
			</keywordSet>
			{$projects/time}
			{$projects/reporting}
	</project>}
</projects>