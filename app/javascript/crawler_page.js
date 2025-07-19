/**
 * Created by robert on 07/07/16.
 */
import Rails from "@rails/ujs";
Rails.start();
console.log("🍪 crawler_page.js loaded!");
function stringToArray(str) {
  // 1) convert single‑quotes to double‑quotes
  const jsony = str.replace(/'/g, '"');
  // 2) parse it as JSON
  return JSON.parse(jsony);
}

var old_crawler_page_id = 1;
function SelectDomain(new_crawler_page_id 
){
    console.log("SelectDomain called")

    const selector_obj =$('[name="domain-selector-'+ new_crawler_page_id+'"]');
 //   selector_obj.show();
    if(new_crawler_page_id != old_crawler_page_id){
        selector_obj =$('[name="domain-selector-'+ old_crawler_page_id+'"]');
 //       selector_obj.hide();
        old_crawler_page_id = new_crawler_page_id;
    }
}
window.SelectDomain = SelectDomain;

function ShowSearchResults()
{
    console.log("ShowSearchResults called");
    var $search_div = $('[id="search-results"]');
    $search_div.show();
    var $search_div = $('[id="instructions"]');
    $search_div.hide();
    var $group_div = $('[id="group-results"]');
    $group_div.hide();
    
}
window.ShowSearchResults = ShowSearchResults;


function ShowGroupResults()
{
    console.log("ShowGroupResults called");
    var $search_div = $('[id="search-results"]');
    $search_div.hide();
    var $search_div = $('[id="instructions"]');
    $search_div.hide();
    var $group_div = $('[id="group-results"]');
    $group_div.show();

}
window.ShowGroupResults = ShowGroupResults;


function ShowHelp()
{
    console.log("ShowHelp called");
    var $search_div = $('[id="search-results"]');
    $search_div.hide();
    var $search_div = $('[id="instructions"]');
    $search_div.show();
    var $group_div = $('[id="group-results"]');
    $group_div.hide();

}
window.ShowHelp = ShowHelp;

function ShowDominicans()
{
    console.log("ShowDominicans called");
    var win = window.open("http://www.op.org", '_blank');
    win.focus();
}
window.ShowDominicans = ShowDominicans;


function Search()
{
    console.log("Search called");
    var $domain_summary_div = $('[name="domain_summary_pages"]');
    var $cloned_summary=$domain_summary_div.clone();
    var $specific_div = $('[id="specific_action_variables"]');
    $specific_div = $specific_div.empty();
    $specific_div.html($cloned_summary);
    $("#search_notice").empty();
    $("#search_notice").text("Please wait ...");
    $("#search_notice").show();
    const form_obj = $('[id="search_form"]');
    Rails.fire(form_obj[0], 'submit');
}
window.Search = Search;


function SelectCrawlerPage( page_id) {
    console.log("SelectCrawlerPage called");
    const ul_ref_obj_str = 'ul-crawler-page-' + page_id;
    const ul_ref_obj = $('[name="ul-crawler-page-'+ page_id+'"]');

    const check_ref_obj = $('[id="checkbox-domain-selector-'+ page_id+'"]');
    if(check_ref_obj.is(':checked'))
    {
        $('[name="ul-crawler-page-'+ page_id+'"]').find(':checkbox').each(function(){ this.checked = true; });
    }
    else
    {
        $('[name="ul-crawler-page-'+ page_id+'"]').find(':checkbox').each(function(){ this.checked = false; });
    }

    //ul_ref_obj.show();

  //  contract_ref_obj = $('[name="contract-button-'+ page_id+'"]');
  //  contract_ref_obj.show();
   // expand_ref_obj = $('[name="expand-button-'+ page_id+'"]');
   // expand_ref_obj.hide();
}
window.SelectCrawlerPage = SelectCrawlerPage;


function CrawlerPageRange(page_id)
{
    console.log("CrawlerPageRange called");
   const crawler_page_id_obj = $('[id="crawler_page_id"]');
    crawler_page_id_obj.attr("value", page_id);
    const crawler_page_action_obj = $('[id="crawler_page_action"]');
    crawler_page_action_obj.attr("value", "page-range");
    const expand_contract_radio_obj = $('[name="expand_contract_radio"]');
    expand_contract_radio_obj.attr("value", true);
    const expand_contract_form_obj = $('[id="expand_contract_form"]');
    Rails.fire(expand_contract_form_obj[0], 'submit');   
}
window.CrawlerPageRange = CrawlerPageRange;



function expandCrawlerPage( page_id) {
    console.log("expandCrawlerPage called");
    //ul_ref_obj_str = 'ul-crawler-page-' + page_id;
    //ul_ref_obj = $('[name="ul-crawler-page-'+ page_id+'"]');

    
    //ul_ref_obj.show();

  //  contract_ref_obj = $('[name="contract-button-'+ page_id+'"]');
   // contract_ref_obj.show();
   // expand_ref_obj = $('[name="expand-button-'+ page_id+'"]');
  //  expand_ref_obj.hide();
    const crawler_page_id_obj = $('[id="crawler_page_id"]');
    crawler_page_id_obj.attr("value", page_id);
    const crawler_page_action_obj = $('[id="crawler_page_action"]');
    crawler_page_action_obj.attr("value", "expand-contract");
    const expand_contract_radio_obj = $('[name="expand_contract_radio"]');
    expand_contract_radio_obj.attr("value", true);
    const expand_contract_form_obj = $('[id="expand_contract_form"]');
    Rails.fire(expand_contract_form_obj[0], 'submit');
}
window.expandCrawlerPage = expandCrawlerPage;


function contractCrawlerPage( page_id) {
    console.log("contractCrawlerPage called");
  //  ul_ref_obj_str = 'ul-crawler-page-' + page_id;
  //  ul_ref_obj = $('[name="ul-crawler-page-'+ page_id+'"]');


 //   ul_ref_obj.hide();

//    contract_ref_obj = $('[name="contract-button-'+ page_id+'"]');
 //   contract_ref_obj.hide();
 //   expand_ref_obj = $('[name="expand-button-'+ page_id+'"]');
//    expand_ref_obj.show();
    const crawler_page_id_obj = $('[id="crawler_page_id"]');
    crawler_page_id_obj.attr("value", page_id);
    const crawler_page_action_obj = $('[id="crawler_page_action"]');
    crawler_page_action_obj.attr("value", "expand-contract");
    const expand_contract_radio_obj = $('[name="expand_contract_radio"]');
    expand_contract_radio_obj.attr("value", false);
    const expand_contract_form_obj = $('[id="expand_contract_form"]');
    Rails.fire(expand_contract_form_obj[0], 'submit');
}
window.contractCrawlerPage = contractCrawlerPage;

function ProcessMore()
{
    console.log("ProcessMore called");
    const form_obj = $('[id="process_more_results_form"]');
    Rails.fire(form_obj[0], 'submit');    
}
window.ProcessMore = ProcessMore;

function MoreResults(more_results_current_index, more_results_range)
{
     console.log("MoreResults called");
    $("#results_current_index").attr("value", more_results_current_index);
    $("#results_range").attr("value", more_results_range);
    const form_obj = $('[id="more_results_form"]');
    Rails.fire(form_obj[0], 'submit');
}
window.MoreResults = MoreResults;

function TidyUp()
{
    console.log("TidyUp called");
   const form_obj = $('[id="tidy_up_form"]');
    Rails.fire(form_obj[0], 'submit');    
}
window.TidyUp = TidyUp;


function SelectPreviousSearch(argss)
{
    console.log("SelectPreviousSearch called");
    const val =  $("#select-previous-search option:selected").val();

    const index =  $("#select-previous-search").prop('selectedIndex');
    const args = stringToArray(argss[index]);
    

    $("#word1").val(args[0]);
    $("#word2").val(args[1]);
    $("#word3").val(args[2]);
    $("#word4").val(args[3]);
    $("#word_separation").val(args[4]).change();
    $("#prev_query_id").val(val);


}
window.SelectPreviousSearch = SelectPreviousSearch;


function HideForms()
{
    console.log("HideForms called");
    $( ".domain-field" ).hide();
    $('[id="domain-summary"]').hide();
    
}
window.HideForms = HideForms;


function HideOptions()
{
    console.log("HideOptions called");
    $('[id="select-domain-div"]').hide();    
}
window.HideOptions = HideOptions;



function SelectDomainAction()
{
    console.log("SelectDomainAction called");
    $("#group_notice").empty();
    const obj = $("#select-domain-action option:selected");
    const value = obj.val();
    switch(value) {
        case "select_action":
            $( ".domain-field" ).hide();
            break;
        case "new_domain":
            $( ".domain-field" ).hide();
            $( ".domain-new" ).show();
            $("#new_domain_action").prop('value', 'new_domain');
            break;
        case "grab_domain":
            $( ".domain-field" ).hide();
            $( ".domain-new" ).show();
            $("#new_domain_action").prop('value', 'grab_domain');
            break;
        
        case "analyse_domain":
            $( ".domain-field" ).hide();
            $( ".domain-new" ).show();
            $(".bad_page").hide();
            $(".domain-checkbox").show();
            $( ".domain-action-button" ).show();
            $("#domain_flow").show();
            $("#domain-action-button").prop('value', 'Analyse Domain');
            break;           
        
        
        case "fix_domain":
            $( ".domain-field" ).hide();
            $( ".domain-new" ).show();
            $(".bad_page").show();
            $(".domain-name-radio").show();
            $( ".domain-action-button" ).show();
            $("#domain-action-button").prop('value', 'Fix Domain');
            break;
        case "reorder_pages":
            $( ".domain-field" ).hide();
            $( ".domain-new" ).show();
            $(".bad_page").show();
            $(".domain-name-radio").show();
            $( ".domain-action-button" ).show();
            $("#domain-action-button").prop('value', 'Reorder Pages');
            break;
        case "deaccent_domain":
            $( ".domain-field" ).hide();
            $( ".domain-new" ).show();
            $(".bad_page").show();
            $(".domain-name-radio").show();
            $( ".domain-action-button" ).show();
            $("#domain-action-button").prop('value', 'Deaccent Domain');
            break;
            
        case "set_paragraphs":
            $( ".domain-field" ).hide();
            $( ".domain-new" ).show();
            $(".bad_page").show();
            $(".domain-name-radio").show();
            $( ".domain-action-button" ).show();
            $("#domain-action-button").prop('value', 'Set Paragraphs');

            break;
        case "search_domain":
            $( ".domain-field" ).hide();
            $(".domain-checkbox").show();
            $(".bad_page").hide();
            $( ".search-new" ).show();
            $(".search-old").show();
            $('[id="search_type"]').prop('value', "search_domains");
            break;
        
        case "search_groups":
            $( ".domain-field" ).hide();
            $(".domain-checkbox").show();
            $(".bad_page").hide();
            $( ".search-new" ).show();
            $(".search-old").show();
            $('[id="search_type"]').prop('value', "search_groups");
            break;
        
        case "move_domain":
            $(".domain-field").hide();
            //$(".domain-name-radio").show();
            $(".domain-checkbox").show();
            $(".move-location-domain-name-radio").show();
            $( ".domain-action-button" ).show();
            $("#domain-action-button").prop('value', 'Move Selected');


            break;
        case "rename":
            $( ".domain-field" ).hide();
            $( ".domain-action-button" ).show();
            $(".domain_action_name").show();
            $(".domain-name-radio").show();
            $("#domain-action-button").prop('value', 'Rename Page');
            
            break;
        case "remove_domain":
            $( ".domain-field" ).hide();
            $( ".remove-domain" ).show();
            $("#domain-action-button").prop('value', 'Remove Page');
            break;


        default:
            alert("something has gone wrong");
    }



}
window.SelectDomainAction = SelectDomainAction;


function SelectGroupAction()
{
    console.log("SelectGroupAction called");
    $("#search_notice").empty();
    $("#group_notice").empty();
    const obj = $("#select-group-action option:selected");
    const value = obj.val();
//alert("value = " + obj.val());
    switch(value) {
        case "select_action":
            $( ".group-field" ).hide();
            break;
        case "new_group":
            $( ".group-field" ).hide();
            $( ".group-action-button" ).show();
            $(".group_action_name").show();
            $(".group-name-radio").show();
            $("#group-action-button").prop('value', 'Create Group');
            $("#group_action_name").text("New Group Name");
            break;

        case "move_group":
            $(".group-field").hide();
            $(".group-name-radio").show();
            $(".move-location-group-name-radio").show();
            $( ".group-action-button" ).show();
            $("#group-action-button").prop('value', 'Move Selected');

           
            break;
        case "add_element":
            $( ".group-field" ).hide();
            $(".search-check-box").show();
            $( ".add-result" ).show();
            ShowSearchResults();
            break;
        case "remove_element":
            $( ".group-field" ).hide();
            $("[name='remove_elements_button']").show();
            
            ShowGroupResults();
            break;

        case "rename":
            $( ".group-field" ).hide();
            $( ".group-action-button" ).show();
            $(".group_action_name").show();
            $(".group-name-radio").show();
            $("#group-action-button").prop('value', 'Rename Group');
            $("#group_action_name").text("New Group Name");
            break;
        case "remove_group":
            $( ".group-field" ).hide();
            $( ".remove-group" ).show();
            $("#group-action-button").prop('value', 'Remove Group');
            break;


        default:
        alert("something has gone wrong");
    }
}
window.SelectGroupAction = SelectGroupAction;

function RemoveFromGroup()
{
    console.log("RemoveFromGroup called");
    const form_obj = $('[id="remove_group_result_form"]');
    Rails.fire(form_obj[0], 'submit');   
}
window.RemoveFromGroup = RemoveFromGroup;


function AddToGroup(group_id)
{
    console.log("AddToGroup called");
    $("#add_elements_group_id").val(group_id);
    const form_obj = $('[id="add_result_form"]');
    Rails.fire(form_obj[0], 'submit');
    
}
window.AddToGroup = AddToGroup;


function RemoveGroup(group_id)
{
    console.log("RemoveGroup called");
    const form_obj = $('[id="group_action_form"]');

    $('[name="remove_group"]').prop('value', group_id);
    Rails.fire(form_obj[0], 'submit');


}
window.RemoveGroup = RemoveGroup;

function RemoveDomain(crawler_page_id)
{
    console.log("RemoveDomain called");
    const form_obj = $('[id="domain_action_form"]');

    $('[name="remove_domain"]').prop('value', crawler_page_id);
    Rails.fire(form_obj[0], 'submit');


}
window.RemoveDomain = RemoveDomain;



function expandGroupName( group_name_id) {
    console.log("expandGroupName called");
    const ul_ref_obj_str = 'ul-group-name-' + group_name_id;
    const ul_ref_obj = $('[name="ul-group-name-'+ group_name_id+'"]');


    ul_ref_obj.show();

    const contract_ref_obj = $('[name="group-contract-button-'+ group_name_id+'"]');
    contract_ref_obj.show();
    const expand_ref_obj = $('[name="group-expand-button-'+ group_name_id+'"]');
    expand_ref_obj.hide();
}
window.expandGroupName = expandGroupName;

function contractGroupName( group_name_id) {
    console.log("contractGroupName called");
    const ul_ref_obj_str = 'ul-group-name-' + group_name_id;
    const ul_ref_obj = $('[name="ul-group-name-'+ group_name_id+'"]');


    ul_ref_obj.hide();

    const contract_ref_obj = $('[name="group-contract-button-'+ group_name_id+'"]');
    contract_ref_obj.hide();
    const expand_ref_obj = $('[name="group-expand-button-'+ group_name_id+'"]');
    expand_ref_obj.show();
}
window.contractGroupName = contractGroupName;




function ShowItem(item_name){

    console.log("ShowItem called");
    const ref_obj = $('[name="'+ item_name+'"]');
    ref_obj.show();
    const show_link_ref_obj_str = "show_link_"+item_name;
    const show_link_ref_obj = $('[name="'+show_link_ref_obj_str+'"]');
    show_link_ref_obj.hide();
    const hide_link_ref_obj_str = "hide_link_"+item_name;
    const hide_link_ref_obj = $('[name="'+hide_link_ref_obj_str+'"]');
    hide_link_ref_obj.show();
}
window.ShowItem = ShowItem;

function HideItem(item_name){
    console.log("HideItem called");
    const ref_str = '[name="'+ item_name+'"]';

    const ref_obj = $(ref_str);
    ref_obj.hide();
    const show_link_ref_obj_str = "show_link_"+item_name;
    const show_link_ref_obj = $('[name="'+show_link_ref_obj_str+'"]');
    show_link_ref_obj.show();
    const hide_link_ref_obj_str = "hide_link_"+item_name;
    const hide_link_ref_obj = $('[name="'+hide_link_ref_obj_str+'"]');
    hide_link_ref_obj.hide();
}
window.HideItem = HideItem;
function selectionNewDomain( page_id) {
    console.log("selectionNewDomain called");


}