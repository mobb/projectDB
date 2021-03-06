xquery version "1.0";
(:	getProjectsPermissions.xql: XQuery to return all projects that have a permission temporal coverage 
	within the query dates..
	
		Parameters:	
			siteId = the three letter site acronym 
			id = (optional) the project ID
			sortBy = (optional) default by title, possible (legal?) values id, surName
			startYear = the earlier date boundary
			endYear = the later date boundary
			xslt = the xslt styelsheet reference to include (not implemented)
			
		Usage Notes:
		
		Attribution:
       Author: Sven Böhm <bohms@lternet.edu>
       Date: 22-Apr-2009
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

(: set output to xhtml with standards-compliant doctype and no xml declaration for IE compatibility :)
declare option exist:serialize "method=xhtml media-type=text/html omit-xml-declaration=yes indent=yes 
        doctype-public=-//W3C//DTD&#160;XHTML&#160;1.0&#160;Transitional//EN
        doctype-system=http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd";

declare function local:yearDate($datestring as xs:string) 
	as xs:gYear {
	    xs:gYear(substring($datestring, 0, 5))};
	

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
let $id := request:get-parameter("id", '')
let $sortBy := request:get-parameter("sortBy", 'title')
let $xslt := request:get-parameter("xlst",'')
let $startYear := request:get-parameter('startYear','1900') cast as xs:string
let $endYear := request:get-parameter('endYear', current-date()) cast as xs:string

(: find the relevant projects within the date range  unless we have an id :)

for $projects in collection(concat('/db/projects/data/',lower-case($site)))/*:researchProject
where local:currentProject($projects, $id, $startYear, $endYear)
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
			{$projects/permissions}
	</project>}
</projects>