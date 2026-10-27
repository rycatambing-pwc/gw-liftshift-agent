#!/usr/bin/env bash
# make-fixture.sh: build a fake PolicyCenter project for testing the LOB removal kit without a
# PolicyCenter install or a build.
#
# The fixture has a made-up LOB to remove (ZQ7, "ZephyrQuest") planted across the file categories
# the kit searches, a kept LOB (KP7) beside it, and traps. Every file is declared below as
#   DELETE  the removal must delete it
#   EDIT    the removal must change it to exactly the "golden" content (only the ZQ7 parts gone)
#   KEEP    the removal must leave it byte-for-byte unchanged (kept LOB, platform files, traps)
# This script is the single source of truth: score-fixture.sh rebuilds the expected end state from it.
# The answer key is NOT written into the fixture, and --install-kit leaves out this evals/ folder,
# so the agent under test cannot read it.
#
# Usage:
#   make-fixture.sh [--out DIR] [--install-kit]    create the fixture (default DIR: evals/fixtures/pc-fixture)
#   make-fixture.sh --print-key                    print the answer key (action <TAB> path)
#   make-fixture.sh --emit-golden DIR              write key.tsv and the golden EDIT files under DIR
#
# Needs: bash 4+, git, tar (only with --install-kit). Nothing is built or installed. The script uses shell
# built-ins for almost everything, because process start-up is slow on some Windows machines.

set -euo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
KIT="$(cd "$HERE/../../.." && pwd)"
OUT="$HERE/fixtures/pc-fixture"; INSTALL_KIT=0; MODE=create; GOLDDIR=""
while [ $# -gt 0 ]; do
  case "$1" in
    --out) OUT="$2"; shift 2 ;;
    --install-kit) INSTALL_KIT=1; shift ;;
    --print-key) MODE=key; shift ;;
    --emit-golden) MODE=golden; GOLDDIR="$2"; shift 2 ;;
    -h|--help) sed -n 2,21p "$0"; exit 0 ;;
    *) echo "unknown option: $1" >&2; exit 1 ;;
  esac
done

# ---- declarations are parsed into these arrays ----
declare -a ACT REL BASE GOLDC
# A line "@@ ACTION path" starts a file ("@/" in the path stands for modules/configuration/). The lines that
# follow are its content. In an EDIT file, a line starting "-|" is written to the fixture without the marker
# and left out of the golden copy.
parse() {
  local line n=-1 rest
  while IFS= read -r line; do
    if [[ $line == '@@ '* ]]; then
      rest="${line#@@ }"; n=$((n+1)); ACT[n]="${rest%% *}"; rest="${rest#* }"
      REL[n]="${rest/#@\//modules/configuration/}"; BASE[n]=""; GOLDC[n]=""
    elif [[ $line == '-|'* ]]; then
      BASE[n]+="${line#-|}"$'\n'
    else
      BASE[n]+="$line"$'\n'; GOLDC[n]+="$line"$'\n'
    fi
  done
}

parse <<'STREAM'
@@ DELETE @/config/extensions/entity/ZQ7Policy_Ext.eti
<?xml version="1.0"?>
<entity xmlns="http://guidewire.com/datamodel" entity="ZQ7Policy_Ext" table="zq7policy_ext" type="retireable" desc="ZephyrQuest boat policy">
  <column name="HullValue" type="currencyamount"/>
</entity>
@@ KEEP @/config/extensions/entity/KP7Policy_Ext.eti
<?xml version="1.0"?>
<entity xmlns="http://guidewire.com/datamodel" entity="KP7Policy_Ext" table="kp7policy_ext" type="retireable" desc="Keystone property policy">
  <column name="BuildingValue" type="currencyamount"/>
</entity>
@@ EDIT @/config/extensions/entity/PolicyPeriod.etx
<extension xmlns="http://guidewire.com/datamodel" entityName="PolicyPeriod">
  <typekey name="KP7Type" typelist="KP7CoverageType"/>
-|  <typekey name="ZQ7Type" typelist="ZQ7CoverageType"/>
  <column name="KP7Score" type="integer"/>
-|  <column name="ZQ7HullClass" type="varchar"/>
</extension>
@@ EDIT @/config/extensions/typelist/PolicyLine.ttx
<typelistextension xmlns="http://guidewire.com/typelists" name="PolicyLine">
  <typecode code="KP7Line" name="Keystone Property" desc="Keystone" priority="10"/>
-|  <typecode code="ZQ7Line" name="ZephyrQuest Boatowners" desc="ZephyrQuest" priority="11"/>
  <typecode code="CPLine" name="Commercial Property" desc="CP" priority="12"/>
</typelistextension>
@@ DELETE @/config/extensions/typelist/InstalledPolicyLineZQ7.ttx
<typelistextension xmlns="http://guidewire.com/typelists" name="InstalledPolicyLine">
  <typecode code="ZQ7" name="ZephyrQuest" desc="Installed line" priority="1"/>
</typelistextension>
@@ DELETE @/config/extensions/typelist/ZQ7CoverageType.tti
<typelist xmlns="http://guidewire.com/typelists" name="ZQ7CoverageType" desc="Boat coverage types">
  <typecode code="Hull" name="Hull" desc="Hull cover" priority="1"/>
</typelist>
@@ KEEP @/config/extensions/typelist/KP7CoverageType.tti
<typelist xmlns="http://guidewire.com/typelists" name="KP7CoverageType" desc="Property coverage types">
  <typecode code="Building" name="Building" desc="Building cover" priority="1"/>
</typelist>
@@ EDIT @/config/extensions/typelist/RuleContextDefinitionKey.ttx
<typelistextension xmlns="http://guidewire.com/typelists" name="RuleContextDefinitionKey">
  <typecode code="KP7Trigger" name="KP7 trigger" desc="trigger" priority="1"/>
-|  <typecode code="ZQ7Trigger" name="ZQ7 trigger" desc="trigger" priority="2"/>
-|  <typecode code="ZQ7Reinstate" name="ZQ7 reinstate" desc="trigger" priority="3"/>
  <typecode code="CPTrigger" name="CP trigger" desc="trigger" priority="4"/>
</typelistextension>
@@ EDIT @/config/extensions/typelist/PropFacCoverageBucket_Ext.tti
<typelist xmlns="http://guidewire.com/typelists" name="PropFacCoverageBucket_Ext" desc="Coverage buckets">
  <typecode code="Property" name="Property" desc="Property bucket" priority="1"/>
-|  <typecode code="Marine" name="ZephyrQuest Marine" desc="Marine bucket" priority="2"/>
  <typecode code="Liability" name="Liability" desc="Liability bucket" priority="3"/>
</typelist>
@@ KEEP @/config/metadata/entity/ZQ_AuditLog.eti
<?xml version="1.0"?>
<entity xmlns="http://guidewire.com/datamodel" entity="ZQ_AuditLog" table="zq_auditlog" type="retireable" desc="Platform audit log">
  <column name="Message" type="longtext"/>
</entity>
@@ KEEP @/config/metadata/typelist/Priority.tti
<typelist xmlns="http://guidewire.com/typelists" name="Priority" desc="Priorities">
  <typecode code="high" name="High" desc="High" priority="1"/>
</typelist>
@@ DELETE @/config/resources/productmodel/policylinepatterns/ZQ7Line/ZQ7Line.xml
<PolicyLinePattern code="ZQ7Line" name="ZephyrQuest Boatowners"/>
@@ DELETE @/config/resources/productmodel/policylinepatterns/ZQ7Line/coverages/ZQ7HullCov.xml
<CoveragePattern code="ZQ7HullCov" name="Hull"/>
@@ KEEP @/config/resources/productmodel/policylinepatterns/KP7Line/KP7Line.xml
<PolicyLinePattern code="KP7Line" name="Keystone Property"/>
@@ EDIT @/config/resources/systables.xml
<systables>
  <systable name="kp7_form_map" file="systables/kp7_form_map.xml"/>
-|  <systable name="zq7_form_map" file="systables/ZQ7_form_map.xml"/>
</systables>
@@ EDIT @/config/resources/systables.CUST.xml
<systables>
-|  <systable name="zq7_liability_map" file="systables/zq7_liability_map.xml"/>
  <systable name="cp_extras" file="systables/cp_extras.xml"/>
</systables>
@@ DELETE @/config/resources/systables/ZQ7_form_map.xml
<map name="zq7_form_map"><entry key="ZQ7-001" value="Hull declaration"/></map>
@@ DELETE @/config/resources/systables/zq7_liability_map.xml
<map name="zq7_liability_map"><entry key="ZQ7-L1" value="Liability"/></map>
@@ KEEP @/config/resources/systables/kp7_form_map.xml
<map name="kp7_form_map"><entry key="KP7-001" value="Building declaration"/></map>
@@ KEEP @/config/resources/systables/cp_extras.xml
<map name="cp_extras"><entry key="CP-1" value="Extra"/></map>
@@ DELETE @/config/rules/ZQ7Rules/ZQ7Events.gr
uses cust.lob.zq7.ZQ7Rating
@@ KEEP @/config/rules/KP7Rules/KP7Events.gr
uses cust.lob.kp7.KP7Rating
@@ EDIT @/config/rules/order.txt
KP7Rules/KP7Events
-|ZQ7Rules/ZQ7Events
CPRules/CPEvents
@@ DELETE @/config/plugin/registry/ZQ7Plugin.gwp
<plugin-gosu interface="IRatePlugin" gosu-class="cust.lob.zq7.ZQ7Rating"/>
@@ KEEP @/config/plugin/registry/KP7Plugin.gwp
<plugin-gosu interface="IRatePlugin" gosu-class="cust.lob.kp7.KP7Rating"/>
@@ EDIT @/config/messaging/messaging-config.xml
<messaging-config>
  <destination id="101" name="KP7 Feed" transport="KP7Transport"/>
-|  <destination id="102" name="ZQ7 Feed" transport="ZQ7Transport">
-|    <event name="ZQ7Bound"/>
-|  </destination>
  <destination id="103" name="CP Feed" transport="CPTransport"/>
</messaging-config>
@@ EDIT @/config/scheduler/scheduler-config.xml
<scheduler-config>
  <process name="KP7Cleanup" class="cust.batch.KP7Cleanup"/>
-|  <process name="ZQ7Cleanup" class="cust.batch.ZQ7Cleanup"/>
  <process name="CPCleanup" class="cust.batch.CPCleanup"/>
</scheduler-config>
@@ EDIT @/config/locale/display.properties
KP7.Dashboard.Title = Keystone Dashboard
-|ZQ7.Dashboard.Title = Marine Dashboard
-|ZQ7.Coverage.HullValue = Hull value
-|ZephyrQuest.Intro = Welcome to ZephyrQuest
Web.Policy.NewSubmission = New Submission
QuestionChoice.qc_8zq7a1 = Night Club
@@ EDIT @/config/locale/display_en_US.properties
KP7CoveredBuilding.Mask = Building
-|ZQ7CoveredVessel.Mask = Vessel
-|ZQ7CoveredCrew.Mask = Crew
Web.Account.Name = Account name
@@ EDIT @/config/locale/display_yy.properties
KP7CoveredBuilding.Mask = Building
-|ZQ7CoveredVessel.Mask = Vessel
Web.Account.Name = Account name
@@ EDIT @/config/locale/productmodel.display.properties
-|ZQ7Line.Question.q1 = Question 1
-|ZQ7Line.Question.q2 = Question 2
-|ZQ7Line.Question.q3 = Question 3
-|ZQ7Line.Question.q4 = Question 4
-|ZQ7Line.Question.q5 = Question 5
-|ZQ7Line.Question.q6 = Question 6
-|ZQ7Line.Question.q7 = Question 7
-|ZQ7Line.Question.q8 = Question 8
-|ZQ7Line.Question.q9 = Question 9
-|ZQ7Line.Question.q10 = Question 10
-|ZQ7Line.Question.q11 = Question 11
-|ZQ7Line.Question.q12 = Question 12
-|ZQ7Line.Question.q13 = Question 13
-|ZQ7Line.Question.q14 = Question 14
-|ZQ7Line.Question.q15 = Question 15
-|ZQ7Line.Question.q16 = Question 16
-|ZQ7Line.Question.q17 = Question 17
-|ZQ7Line.Question.q18 = Question 18
-|ZQ7Line.Question.q19 = Question 19
-|ZQ7Line.Question.q20 = Question 20
-|ZQ7Line.Question.q21 = Question 21
-|ZQ7Line.Question.q22 = Question 22
-|ZQ7Line.Question.q23 = Question 23
-|ZQ7Line.Question.q24 = Question 24
-|ZQ7Line.Question.q25 = Question 25
-|ZQ7Line.Question.q26 = Question 26
-|ZQ7Line.Question.q27 = Question 27
-|ZQ7Line.Question.q28 = Question 28
-|ZQ7Line.Question.q29 = Question 29
-|ZQ7Line.Question.q30 = Question 30
-|ZQ7Line.Question.q31 = Question 31
-|ZQ7Line.Question.q32 = Question 32
-|ZQ7Line.Question.q33 = Question 33
-|ZQ7Line.Question.q34 = Question 34
-|ZQ7Line.Question.q35 = Question 35
-|ZQ7Line.Question.q36 = Question 36
-|ZQ7Line.Question.q37 = Question 37
-|ZQ7Line.Question.q38 = Question 38
-|ZQ7Line.Question.q39 = Question 39
-|ZQ7Line.Question.q40 = Question 40
KP7Line.Question.q1 = Question 1
KP7Line.Question.q2 = Question 2
CPLine.Question.q1 = Question 1
@@ EDIT @/config/locale/typelist.properties
TypeKey.PolicyLine.KP7Line = Keystone Property
-|TypeKey.PolicyLine.ZQ7Line = ZephyrQuest Boatowners
-|TypeKey.ZQ7CoverageType.Hull = Hull
-|TypeKey.InstalledPolicyLine.ZQ7 = ZephyrQuest
TypeKey.PolicyLine.CPLine = Commercial Property
@@ EDIT @/config/locale/typelist_en_US.properties
TypeKey.PolicyLine.KP7Line = Keystone Property
-|TypeKey.PolicyLine.ZQ7Line = ZephyrQuest Boatowners
@@ EDIT @/config/locale/typelist_yy.properties
TypeKey.PolicyLine.KP7Line = Keystone Property
-|TypeKey.PolicyLine.ZQ7Line = ZephyrQuest Boatowners
@@ EDIT @/config/locale/typelist_es.properties
TypeKey.PolicyLine.KP7Line = Propiedad Keystone
-|TypeKey.PolicyLine.ZQ7Line = Lanchas
-|TypeKey.ZQ7CoverageType.Hull = Casco
@@ EDIT @/config/locale/typelist_es_ES.properties
TypeKey.PolicyLine.KP7Line = Propiedad Keystone
-|TypeKey.PolicyLine.ZQ7Line = Embarcaciones
@@ EDIT @/config/locale/schema.display.properties
KP7Policy.BuildingValue = Building value
-|ZQ7Policy.HullValue = Hull value
@@ EDIT @/config/locale/schema.display_en_US_EDG.properties
KP7Policy.BuildingValue = Building value
-|ZQ7Policy.HullValue = Hull value
@@ EDIT @/config/locale/schema.display_en_US_EDG_PH.properties
KP7Policy.BuildingValue = Building value
-|ZQ7Policy.HullValue = Hull value
@@ EDIT @/config/smoketests/typelists.properties
KP7CoverageType=1
-|ZQ7CoverageType=1
Priority=1
@@ EDIT @/config/statesets/StateSets.xml
<StateSets>
  <StateSet name="KP7States"><State code="NY"/></StateSet>
-|  <StateSet name="ZQ7States"><State code="FL"/></StateSet>
</StateSets>
@@ EDIT @/config/resources/ResourceContextMap.xml
<ResourceContextMap>
  <context type="KP7Line" resource="kp7"/>
-|  <context type="ZQ7Line" resource="zq7"/>
</ResourceContextMap>
@@ EDIT @/config/xml/config.xml
<config>
  <param name="KP7Rating" value="true"/>
-|  <param name="ZQ7RatingEnabled" value="true"/>
  <param name="MaxItems" value="100"/>
</config>
@@ DELETE @/config/integration/apis/installedlobs/zq7_ext-1.0.yaml
openapi: 3.0.0
info:
  title: ZQ7 extension API
@@ EDIT @/config/integration/apis/policyperiod_ext-1.0.schema.json
{
  "PolicyType": {
    "enum": [
      "KP7Line",
-|      "ZQ7Line",
      "CPLine"
    ]
  }
}
@@ DELETE @/config/extensions/displayname/ZQ7Building.en
ZQ7Building = Vessel hull
@@ DELETE @/config/extensions/displayname/ZQ7Building.es
ZQ7Building = Casco de la embarcacion
@@ EDIT @/config/extensions/displayname/TerritoryCode.en
KP7Valley = Valley
-|ZQ7Harbor = Harbor
CPCentral = Central
@@ DELETE @/config/content/cust-ratebooks/ZQ7/ratebook.xml
<ratebook name="ZQ7 rates"><rate code="ZQ7-1" value="1.20"/></ratebook>
@@ KEEP @/config/content/cust-ratebooks/KP7/ratebook.xml
<ratebook name="KP7 rates"><rate code="KP7-1" value="1.10"/></ratebook>
@@ DELETE @/config/content/submissionintake/Mapping Script_ZQ7Line.kts
map("ZQ7Line", "hull")
@@ DELETE @/config/resources/zq7-availability-config.xml
<availability line="ZQ7"><rule coverage="Hull" available="true"/></availability>
@@ KEEP @/config/resources/kp7-availability-config.xml
<availability line="KP7"><rule coverage="Building" available="true"/></availability>
@@ DELETE @/config/import/bizrules/ZQ7_bootstrap.xml
<bizrules line="ZQ7"/>
@@ EDIT @/config/bizrules/bootstrap.xml
<bootstrap>
  <import file="KP7_bootstrap.xml"/>
-|  <import file="ZQ7_bootstrap.xml"/>
</bootstrap>
@@ DELETE @/config/web/pcf/line/zq7/ZQ7LineWizard.pcf
<PCF><Wizard id="ZQ7LineWizard"/></PCF>
@@ DELETE @/config/web/pcf/line/zq7/ZQ7Panel.pcf
<PCF><Panel id="ZQ7Panel"/></PCF>
@@ KEEP @/config/web/pcf/line/kp7/KP7LineWizard.pcf
<PCF><Wizard id="KP7LineWizard"/></PCF>
@@ EDIT @/config/web/pcf/line/common/LineWizardStepSet.pcf
<PCF>
  <WizardStepSet id="LineWizardStepSet">
    <WizardStepSet id="KP7Steps" def="KP7LineWizard()"/>
-|    <WizardStepSet id="ZQ7Steps" def="ZQ7LineWizard()"/>
    <WizardStepSet id="CPSteps" def="CPLineWizard()"/>
  </WizardStepSet>
</PCF>
@@ EDIT @/config/web/pcf/policy/PolicyMenu.pcf
<PCF>
  <MenuItem id="KP7Dash" label="displaykey.KP7.Dashboard.Title"/>
-|  <MenuItem id="ZQ7Dash" label="displaykey.ZQ7.Dashboard.Title"/>
  <MenuItem id="Notes" label="displaykey.Web.Notes"/>
</PCF>
@@ DELETE @/gsrc/gw/lob/zq7/ZQ7Helper.gs
package gw.lob.zq7

class ZQ7Helper {
  static function code() : String { return "ZQ7" }
}
@@ DELETE @/gsrc/cust/lob/zq7/ZQ7Rating.gs
package cust.lob.zq7

class ZQ7Rating {
  static function rate() : int { return 0 }
}
@@ KEEP @/gsrc/gw/lob/kp7/KP7Helper.gs
package gw.lob.kp7

class KP7Helper {
  static function code() : String { return "KP7" }
}
@@ KEEP @/gsrc/cust/lob/kp7/KP7Rating.gs
package cust.lob.kp7

class KP7Rating {
  static function rate() : int { return 0 }
}
@@ EDIT @/gsrc/cust/lob/common/LobCommonHelperFactory.gs
package cust.lob.common

class LobCommonHelperFactory {
  static function forLine(code : String) : String {
    switch (code) {
      case "KP7Line":
        return "kp7"
-|      case "ZQ7Line":
-|        return "zq7"
      case "CPLine":
        return "cp"
      default:
        return "common"
    }
  }
}
@@ EDIT @/gsrc/cust/uw/UnderwriterEvaluatorTriggeringPoint_Ext.gs
package cust.uw

class UnderwriterEvaluatorTriggeringPoint_Ext {
  static var TRIGGERS = {
    "KP7Trigger",
-|    "ZQ7Trigger",
-|    "ZQ7Reinstate",
    "CPTrigger"
  }
}
@@ EDIT @/gsrc/cust/common/CommonConstants_Ext.gs
package cust.common

class CommonConstants_Ext {
  static final var KP7_ELIGIBLE = "KP7_OK"
-|  static final var ZQ7_ELIGIBLE = "ZQ7_OK"
-|  static final var ZQ7_PRODUCTCODE_EXT = "ZQ7"
}
@@ EDIT @/gsrc/cust/pc/AccountHelper_Ext.gs
package cust.pc

class AccountHelper_Ext {
  static function eligible(a : String) : boolean {
    if (a == CommonConstants_Ext.KP7_ELIGIBLE) { return true }
-|    if (a == CommonConstants_Ext.ZQ7_ELIGIBLE) { return true }
    return false
  }
}
@@ KEEP @/gsrc/gw/lob/common/AvailabilityLoader.gs
package gw.lob.common

class AvailabilityLoader {
  static function fileFor(abbreviation : String) : String {
    return abbreviation.toLowerCase() + "-availability-config.xml"
  }
}
@@ EDIT @/gsrc/cust/doc/PolicyDocument_Ext.gst
<%@ params(policy : PolicyPeriod) %>
Policy ${policy.PolicyNumber}
<% if (policy.KP7Score != null) { %>
KP7 score: ${policy.KP7Score}
<% } %>
-|<% if (policy.ZQ7HullClass != null) { %>
-|ZQ7 hull class: ${policy.ZQ7HullClass}
-|<% } %>
Thank you.
@@ DELETE @/gtest/cust/lob/ZQ7RatingTest.gs
package cust.lob

class ZQ7RatingTest {
  function testRate() {}
}
@@ KEEP @/gtest/cust/lob/KP7RatingTest.gs
package cust.lob

class KP7RatingTest {
  function testRate() {}
}
@@ EDIT @/gtest/cust/mock/SampleData.gs
package cust.mock

class SampleData {
  static var NAMES = {
    "Keystone Sample",
-|    "ZephyrQuest Sample",
    "Central Sample"
  }
}
STREAM

# ---- true if the text mentions the removed LOB at a word start (case-insensitive) ----
mentions() { local lc="${1,,}"; [[ $lc =~ (^|[^a-z0-9_])(zq7|zephyrquest) ]]; }

selfcheck() {  # every declaration must match what it claims
  local i bad=0
  for i in "${!REL[@]}"; do
    case "${ACT[i]}" in
      DELETE) mentions "${BASE[i]}" || mentions "${REL[i]}" || { echo "SELFCHECK DELETE never mentions the LOB: ${REL[i]}" >&2; bad=1; } ;;
      EDIT)   mentions "${BASE[i]}" || { echo "SELFCHECK EDIT has no LOB lines: ${REL[i]}" >&2; bad=1; }
              ! mentions "${GOLDC[i]}" || { echo "SELFCHECK golden still mentions the LOB: ${REL[i]}" >&2; bad=1; }
              [ "${BASE[i]}" != "${GOLDC[i]}" ] || { echo "SELFCHECK EDIT changes nothing: ${REL[i]}" >&2; bad=1; } ;;
      KEEP)   ! mentions "${BASE[i]}" && ! mentions "${REL[i]}" || { echo "SELFCHECK KEEP mentions the LOB: ${REL[i]}" >&2; bad=1; } ;;
      *)      echo "SELFCHECK bad action ${ACT[i]} for ${REL[i]}" >&2; bad=1 ;;
    esac
  done
  return $bad
}

write_key() { local i; for i in "${!REL[@]}"; do printf '%s\t%s\n' "${ACT[i]}" "${REL[i]}"; done; }

# write the files of the chosen kind under $1; $2 = BASE or GOLD
write_files() {
  local root="$1" which="$2" i d f; local -a dirs=(); local -A seen=()
  for i in "${!REL[@]}"; do
    [ "$which" = GOLD ] && [ "${ACT[i]}" != EDIT ] && continue
    d="${REL[i]%/*}"
    [ -z "${seen[$d]:-}" ] && { seen[$d]=1; dirs+=("$root/$d"); }
  done
  mkdir -p "${dirs[@]}"
  for i in "${!REL[@]}"; do
    f="$root/${REL[i]}"
    if [ "$which" = BASE ]; then printf '%s' "${BASE[i]}" > "$f"
    elif [ "${ACT[i]}" = EDIT ]; then printf '%s' "${GOLDC[i]}" > "$f"; fi
  done
}

selfcheck || { echo "Fixture declarations failed their self-check." >&2; exit 1; }

case "$MODE" in
  key)    write_key; exit 0 ;;
  golden) mkdir -p "$GOLDDIR"; write_key > "$GOLDDIR/key.tsv"; write_files "$GOLDDIR/golden" GOLD; exit 0 ;;
esac

# ---------------- create the fixture ----------------
if [ -e "$OUT" ] && [ -n "$(ls -A "$OUT" 2>/dev/null)" ]; then
  echo "Refusing to overwrite a non-empty folder: $OUT (delete it first)" >&2; exit 1
fi
mkdir -p "$OUT"; ROOT="$(cd "$OUT" && pwd)"
write_files "$ROOT" BASE

printf '@echo off\r\necho FIXTURE: this is a test fixture, not a PolicyCenter install. gwb %%* was NOT run.\r\nexit /b 9\r\n' > "$ROOT/gwb.bat"
printf '.claude/\n.pwc/\ntmp/\nenv-description.md\n' > "$ROOT/.gitignore"
# decoys for the H2 path rule: the server's database is the one under the config module
mkdir -p "$ROOT/tmp" "$ROOT/modules/configuration/tmp"
: > "$ROOT/tmp/pc.mv.db"; : > "$ROOT/modules/configuration/tmp/pc.mv.db"; : > "$ROOT/modules/configuration/tmp/pc.lock.db"

if [ "$INSTALL_KIT" = 1 ]; then
  mkdir -p "$ROOT/.claude"
  ( cd "$KIT" && tar --exclude='skills/pc-plan-lob-removal/evals' --exclude='.git' -cf - agents context rules skills tools contributing README.md ) | tar -C "$ROOT/.claude" -xf -
fi

git -C "$ROOT" init -q -b main
printf '[user]\n\tname = fixture\n\temail = fixture@example.invalid\n[core]\n\tautocrlf = false\n' >> "$ROOT/.git/config"
git -C "$ROOT" add -A
git -C "$ROOT" commit -q -m "chore: add fixture baseline"
git -C "$ROOT" tag fixture-baseline
echo "Fixture ready: $ROOT  (${#REL[@]} declared files, tag fixture-baseline)"
echo "LOB to remove: ZQ7 (alternate name: ZephyrQuest). Kept LOB: KP7. Config root: modules/configuration"
if [ "$INSTALL_KIT" = 1 ]; then echo "Kit installed in $ROOT/.claude. Start Claude Code from $ROOT"
else echo "Re-run with --install-kit to copy the kit into the fixture."; fi
