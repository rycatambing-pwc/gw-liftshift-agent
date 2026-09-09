## Context



## Workflow
This workflow will be followed by the agents when executing each of the steps indicated.

1. Before starting verify the agent-logs folder exists it should be in the project folder with the path and name  ```.pwc/agent/work-logs```.
2. Create a log file in this folder using indicating the timestamp of the run as the file name.
3. For each action or task below indicate the timestamp, the step performed, relevant information and the impacted files. If a user was queried, indicate the user response.
4. Ask the user which LOB code will be removed. Follow-up if there are alternate name for example, for an LOB code "CU" may also be referred to as "Customer Umbrella".
5. The agent must check if the exit criteria is met for each phase. Make sure to do the following:
    - log if the exit criteria are met or not
    - Notify the user before proceeding do not continue without confirmation.
6. Before troubleshooting lookup if there are solutions in the lessons folder located in  ```.pwc/agent/lessons```
7. Instruct the agents that LOB code is case insensitive. 

## Guidewire Policy Center LOB Removal Workflow 

0. **Common Tasks**
    - Before opening any terminal run the batch file ```pc-init-env.bat```.  This batch file will set the environment variables before running any gwb related tasks. If you cannot find the batch file, then create one, it should set the following environment variables:
        - JAVA_HOME environment variable that is at least JDK 21
        - IDEA_HOME - environment variable at least version from 2024 onwards.

1.  **Establish the Baseline**
    The intent of this section is to establish that the current Guidewire Policy Center is configured correctly with the tools installed in the host machine. 

    **Tasks:**
    
    - [ ] Run skill pc-current-state
    - [ ] Ask the user to disable the APD / Iapd Service Plugin    
    - [ ] Open a terminal
    - [ ] Run in the terminal gwb clean
    - [ ] Run in the terminal gwb compile
    - [ ] Run in the terminal gwb runServer. 

    **Exit Criteria**
    - The task ```gwb clean``` must run successfully.
    - The task ```gwb compile``` must run successfully.
    - The task ```gwb runServer``` must run successfully.
        
2. **Remove LOB PCF Files**

    **Tasks:**
    - [ ] Delete the folder and its content under the folder ```configuration/config/web/pcf/line/[lob_code]```
    - [ ] Delete the folder ```configuration/config/productmodel/policylinepatterns/<lob>Line```
    - [ ] Delete the file following the pattern ```[lob_code]ManuscriptEndorsementPopup.pcf```
    - [ ] Run `pcf-find-usages` against all PCF files in `configuration/config/web/pcf/line/[lob_code]` to produce a reference map of consumers
    - [ ] Remove or update `PanelRef`/`InputSetRef` elements in base PCFs whose `def` targets a deleted file
    - [ ] Remove `LocationRef` entries in LocationGroup PCFs pointing to deleted LOB pages
    - [ ] Find and delete LOB-specific mode files outside the LOB folder (e.g., in `line/common/`)
    - [ ] Remove LOB entries from shared navigation PCFs (`LineWizardStepSet`, `PolicyMenuItemSet`, etc.)
    - [ ] Next we run ```gwb codegen```, it is expected that no errors will be raised at this point.

    **Exit Criteria**
    - Deletion tasks are successfully completed.
    - No broken PanelRef, InputSetRef, or LocationRef references remain in base PCFs.
    - The task ```gwb codegen``` has run successfully.

3. **Remove Gosu Files**

    **Tasks:**
    - [ ] Navigate to ```/configuration/gsrc/gw/lob``` folder and delete the child folders matching the lob_code pattern.  For example if the lob_code is UPL, then delete the folder in ```/configuration/gsrc/gw/lob/upl```
    - [ ] Navigate to ```/configuration/gsrc/gw/cust/lob``` folder and delete the child folders matching the lob code pattern.
    - [ ] Navigate to ```/configuration/gsrc/ext/lob``` and delete the child folder matching the lob_code pattern.
    - [ ] Navigate to ```/configuration/gsrc/gw/ext/sbt/bizrules/builder``` and delete the child folder matching the lob code pattern.
    - [ ] Navigate to ```/configuration/gsrc/gw/webservice/pc/pc5000/ccintegration/lob``` and delete the file matching the pattern ```CC[lob_code]```.
    - [ ] Navigate to ```/configuration/gsrc/gw/webservice/pc/pc900/ccintegration/lob``` and delete the file matching the pattern ```CC[lob_code]```.
    - [ ] Navigate to ```/configuration/gsrc/gw/webservice/pc/pc910/ccintegration/lob``` and delete the file matching the pattern ```CC[lob_code]```.

    **Exit Criteria**
    - Deletion tasks are successfully completed.


4. **Refactor Gosu Files**		
    1.	Task the gosu-agent to edit the files below and remove uses declaration, variables and lines of code that references the lob code.
        ```
        - /gsrc/cust/lob/common/LobCommonAdditionalInsuredHelperFactory.gs
        - /gsrc/cust/lob/common/schedules/LobScheduleColumnHelperFactory.gs
        - /gsrc/cust/lob/common/validation/PolicyPeriodValidation_Ext.gs
        - /gsrc/cust/pc/preupdate/PreUpdateHandler_Ext.gs
        - /gsrc/cust/plugin/rateflow/RateQueryWithFailoverLookupPlugin_Ext.gs
        - /gsrc/gw/policylocation/PolicyLocationEnhancement.gsx
        - /gsrc/gw/lob/common/LobPropertyServices.gs
        - /gsrc/gw/rest/ext/pc/job/v1/JobApiExtHandler.gs
        - /gsrc/gw/rest/internal/pc/dgc/job/v1/coverage/CovTermEnhancementDgc.gsx

    **Exit Criteria**
    - Deletion tasks are successfully completed.
    - Run ```gwb compile``` must run successfully.


5. **BizRules Bootstrap Updates**
    **Tasks:**
    - [ ] Navigate to the folder ```/configuration/config/import/bizrules```.
    - [ ] Find and delete the gwrules files that have a prefix matching the lob_code, for example to delete gwrules file for BP7 lob then the file BP7_PharmacistsCoverage_Ext.gwrules matches.
    - [ ] Task the entity-agent to remove [lob_code] references in the file ```AppCritLineOfBusiness.eti```.

    **Exit Criteria**
    - Deletion tasks have completed successfully.
    - No [lob_code] references in ```AppCritLineOfBusiness.eti``` file.
        
6. **Update Configuration Files**	

    **Tasks:**
    - [ ] Navigate to the project folder ```configuration/config/resources/systables```
    - [ ] Delete the files matching the pattern ```custom_form_inference.[lob_code].xml```.  For example for lob_code BP7, then the file to be deleted would be named ```custom_form_inference.BP7.xml```.
    - [ ] In the same folder, Delete the files matching the pattern ```[lob_code]-*.xml```
    - [ ] Navigate to the project folder ```/configuration/config/resources```.
    - [ ] Delete the files matching the pattern ```systables.[lob_code].xml```. For example for if the [lob_code] is "BP7", then the file to be deleted will be ```systables.BP7.xml```
    - [ ] In the same folder, Delete the files matching the pattern ```[lob_code]-*.xml```.
    - [ ] Navigate to the folder ```/configuration/config/content/submissionintake```.
    - [ ] Delete the files matching ```Mapping Script_[lob_code]Line.kts```. For example if the [lob_code] is BP7 then the file to be deleted would  be named ```Mapping Script_BP7Line.kts```.
    - [ ] Navigate to the folder ```/configuration/config/locale```.
    - [ ] Task the config-agent to modify the ```display.properties``` file based on the following rules:

        ```
        a. Find all the properties matching the pattern ```*.[lob_code].*```, for example if BP7 is the lob_code, the properties like "Builder.BP7.Jurisdiction.Error.CouldNotAdd", "Web.Differences.LOB.BP7.Conditions", "BP7.text", "Web.Policy.BP7.Validation.TooManySheduleItems".
        b. Ask the user if he wants to view the properties to be removed. If he says yes, then report all properties found matching the criteria and indicate they will be removed.
        c. Ask the user to proceed, if he says yes then proceed to remove the property entries.
        d. Ensure that after deletion the properties file format is valid and intact.
        ```

    - [ ] Navigate to the project folder ```/configuration/config/displaynames```
    - [ ] Find the displaynames files (*.en) following the LOB naming pattern with [lob_code] as the prefix of the entity. For example the [lob_code] is BP7, then displayname files like "BP7Building.en"
    - [ ] Proceed to delete the matching displayname files.

    **Exit Criteria**
    - Tasks completed successfully.
    - The file ```display.properties``` has been updated successfully.

7. **Ratebook Removal**	

    **Tasks:**
    - [ ] Navigate to the folder ```/configuration/config/content/cust-ratebooks```.
    - [ ] Delete the child folder matching the [lob_code].
    - [ ] Navigate to the folder ```/configuration/config/content/iso-ratebooks```.
    - [ ] Delete the child folder matching the [lob_code].
    - [ ] Delete the file ```/configuration/build/idea/classes/updates/adopted/SBT*[lob_code]*.zip``` if it exists.
        
    **Exit Criteria**
    - Deletion tasks have completed successfully.

        
8. **Cleanup API Enablement Config**

    **Tasks:**
    - [ ] Navigate to the folder ```/configuration/config/integration/apis/installedlobs```.
    - [ ] Find and delete the file matching the pattern ```[lob_code]_ext-1.0.yaml```.
    - [ ] Find and delete the file matching the pattern ```[lob_code]_codegen_config_ext-1.0.yaml```.
    - [ ] Open a terminal and run ```gwb clean```
    - [ ] In the same terminal run ```gwb codegen```

    **Exit Criteria**
    - Deletion tasks have completed successfully.
    - Running the task ```gwb codegen``` completed successfully.

9. **Remove Entity Extensions**

    **Tasks:**
    - [ ] Cleanup Generated folder, run ```gwb clean```.
    - [ ] Navigate to the folder ```/configuration/config/extensions/entity```
    - [ ] Find the entity files (*.eti,  *.etx, *.eix) following the LOB naming pattern with lob_code as the prefix of the entity. For example the lob_code BP7, then entity files like "BP7Building.etx", "BP7Building.eti"
    - [ ] Report and list down the name of the entity files that matches and indicate they will be deleted.  Ask the user if you will proceed.
    - [ ] Delete the matching entity files in the list.
    - [ ] Delete any file matching ```[lob_code].state.etx``` 
    - [ ] Delete any file matchingand ```[lob_code].CUST.etx```
    - [ ] Delete any file matching ```PolicyPeriod.[lob_code].etx```
    - [ ] Run ```gwb codegen```

    **Exit Criteria**
    - Deletion tasks are successfully completed.
    - Validate the generated Java files are no longer in the generated folder.

10. **Cleanup Typelist**		

    **Tasks:**
    - [ ] Open a terminal and navigate to the folder ```configuration/config/extensions/typelist```.
    - [ ] Find and delete the file matching the pattern ```InstalledPolicyLine[lob_code].ttx```.
    - [ ] Task the typelist-agent to remove entries from ```PolicyLine.ttx``` matching the [lob_code].
    - [ ] Run ```gwb clean```.
    - [ ] Run ```gwb codegen```

    **Exit Criteria**
    - Deletion tasks are successfully completed.
    - Validate the generated Java files are no longer in the generated folder.

12. **Milestone Check**

    **Tasks:**
    - [ ] Run ```gwb codegen```, should there be any errors task the gw-config-agent to do the following:
        1. Identify the error and generate a plan to fix the error.  Save the plan to a markdown file for user review.
        2. Present the plan to the user for approval.
        3. Upon approval implement the updates.
        4. Run in  until all compile errors are resolved.

    - [ ] Run ```gwb compile```, should there be any errors task the gw-gosu-agent to do the following:
        1. Identify the error and generate a plan to fix the error.  Save the plan to a markdown file for user review.
        2. Present the plan to the user for approval.
        3. Upon approval uset the plan saved as a markdown file to implement the fixes.
        4. Run in  until all compile errors are resolved.

    **Exit Criteria:**
    - The task ```gwb codegen``` completes successfully.
    - The task ```gwb compile``` completes successfully.

        
13. **Gunit Test Updates**		
    
    **Tasks:**
    - [ ] Task the gosu-agent to fix compile and test errors for an existing codebase and do not stop until all gunit test are fixed.
    - [ ] Run the test suite by executing the command gwb runSuite
    - [ ] Task the gosu-agent to fix broken unit tests.
        

    **Exit Criteria**
    - All unit tests successfully completed.
        
