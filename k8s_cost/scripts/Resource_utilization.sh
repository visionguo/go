#!/bin/bash

# Description: k8s Resource utilization
# Author: guoshaogang@baidu.com
# Date: 2020-05-19

UTILIZATION_NAMESPACE=""
UTILIZATION_NODE_LABEL=""
UTILIZATION_CONTEXT=""
UTILIZATION_SUBCOMMAND=""
UTILIZATION_UNITS="full"
UTILIZATION_HEADERS="true"
UTILIZATION_OUTPUT="text"

print_help() {
  echo "namespace  shows namespace Resource utilization" >&2
  echo "node       shows node Resource utilization" >&2
  echo "-n         filter by namespace" >&2
  echo "-l         filter by node label" >&2
  echo "-h         shows help" >&2
  echo "context    shows The name of kubeconfig context to use" >&2
  echo ""          >&2
  exit
}

#Get pod data by go-template
get_pod_data() {
  local template
  local namespace
  local context

  read -r -d '' template <<'EOF'
  {{/* get_pod_data */}}
  {{ range .items }}
    {{ $namespace:=.metadata.namespace }}
    {{ $node:=.spec.nodeName }}
    {{ range .spec.containers }}
      {{ $namespace }}
      {{ "\t" }}
      {{ $node }}
      {{"\t"}}

      {{ if .resources.requests.cpu }}
        {{ .resources.requests.cpu }}
      {{ else }}
        0
      {{end}}
      {{ "\t" }}

      {{ if .resources.requests.memory }}
        {{ .resources.requests.memory }}
      {{ else }}
        0Ki
      {{end}}
      {{ "\t" }}

      {{ if .resources.limits.cpu }}
        {{ .resources.limits.cpu }}
      {{ else }}
        0
      {{end}}
      {{ "\t" }}

      {{ if .resources.limits.memory }}
        {{ .resources.limits.memory }}
      {{ else }}
        0Ki
      {{end}}
      {{ "\n" }}
    {{end}}
  {{end}}
EOF

#debug
  if [ "${UTILIZATION_NAMESPACE}" != "" ]; then
    namespace="--namespace=${UTILIZATION_NAMESPACE}"
  else
    namespace="--all-namespaces"
  fi

  if [ "${UTILIZATION_CONTEXT}" != "" ]; then
    context="--context=${UTILIZATION_CONTEXT}"
  else
    context=""
  fi

#Get the pod by field-selector
  kubectl $context get pod $namespace --field-selector=status.phase=Running -o=go-template --template="${template//[$' \t\r\n']}"
}

#Get node data by go-template
get_node_data () {
  local node_label
  local context

  if [ "${UTILIZATION_NODE_LABEL}" != "" ]; then
    node_label="-l ${UTILIZATION_NODE_LABEL}"
  fi
  if [ "${UTILIZATION_CONTEXT}" != "" ]; then
    context="--context=${UTILIZATION_CONTEXT}"
  else
    context=""
  fi

#Get the node by field-selector
  kubectl $context get nodes $node_label --field-selector=spec.unschedulable=false -o=jsonpath="{range .items[*]}{.metadata.name}{'\t'}{.status.allocatable.cpu}{'\t'}{.status.allocatable.memory}{'\n'}{end}"
}

#Get cluster utilization
cluster_utilization() {
  awkcmd='BEGIN {FS="\t"};
  NR==FNR { node[$1]; }

  NR==FNR && $2 ~ /[0-9]$/     { alloc_cpu+=$2*1000; };
  NR==FNR && $2 ~ /m?$/        { alloc_cpu+=$2; };
  NR==FNR && $3 ~ /[KK](i)?$/  { alloc_mem+=$3*1024; next };
  NR==FNR && $3 ~ /M(i)?$/     { alloc_mem+=$3*1048576; next };
  NR==FNR && $3 ~ /[gG](i)?$/  { alloc_mem+=$3*1073741824; next };

  #cpu requests
  $2 in node && $3 ~ /[0-9]$/ { req_cpu+=$3*1000; };
  $2 in node && $3 ~ /m?$/    { req_cpu+=$3; };

  #memory requests
  $2 in node && $4 ~ /m$/         { req_mem+=$4/1000; next };
  $2 in node && $4 ~ /[KK](i)?$/  { req_mem+=$4*1024; };
  $2 in node && $4 ~ /M(i)?$/     { req_mem+=$4*1048576; };
  $2 in node && $4 ~ /[gG](i)?$/  { req_mem+=$4*1073741824; };
  $2 in node && $4 ~ /[tT](i)?$/  { req_mem+=$4*1099511627776; };

  #cpu limits
  $2 in node && $5 ~ /[0-9]$/     { lim_cpu+=$5*1000; };
  $2 in node && $5 ~ /m?$/        { lim_cpu+=$5; };

  #memory limits
  $2 in node && $6 ~ /m$/         { lim_mem+=$6/1000; next };
  $2 in node && $6 ~ /[KK](i)?$/  { lim_mem+=$6*1024; next };
  $2 in node && $6 ~ /M(i)?$/     { lim_mem+=$6*1048576; next };
  $2 in node && $6 ~ /[gG](i)?$/  { lim_mem+=$6*1073741824; next };
  $2 in node && $6 ~ /[tT](i)?$/  { lim_mem+=$6*1099511627776; next };

  END {
    req_cpu_text=prettify(req_cpu, cpu_pretty(req_cpu))
    req_mem_text=prettify(sprintf("%.0f",req_mem), mem_pretty(req_mem))
    req_header=prettify("Requests", "Req")
    req_width=calc_max_width(req_header, req_cpu_text, req_mem_text)

    percent_req_cpu_text=prettify(calc_percentage(req_cpu, alloc_cpu), sprintf("%s%%", calc_percentage(req_cpu, alloc_cpu)))
    percent_req_mem_text=prettify(calc_percentage(req_mem, alloc_mem), sprintf("%s%%", calc_percentage(req_mem, alloc_mem)))
    percent_req_header=prettify("%Requests", "%R")
    percent_req_width=calc_max_width(percent_req_header, percent_req_cpu_text, percent_req_mem_text)

    lim_cpu_text=prettify(lim_cpu, cpu_pretty(lim_cpu))
    lim_mem_text=prettify(lim_mem, mem_pretty(lim_mem))
    lim_header=prettify("Limits", "Lim")
    lim_width=calc_max_width(lim_header, lim_cpu_text, lim_mem_text)

    percent_lim_cpu_text=prettify(calc_percentage(lim_cpu, alloc_cpu), sprintf("%s%%", calc_percentage(lim_cpu, alloc_cpu)))
    percent_lim_mem_text=prettify(calc_percentage(lim_mem, alloc_mem), sprintf("%s%%", calc_percentage(lim_mem, alloc_mem)))
    percent_lim_header=prettify("%Limits", "%L")
    percent_lim_width=calc_max_width(percent_lim_header, percent_lim_cpu_text, percent_lim_mem_text)

    if ( output == "text") {
        if ( headers == "true" ) {
            printf("%-8s  %"req_width"s  %"percent_req_width"s  %"lim_width"s  %"percent_lim_width"s\n", "Resource", req_header, percent_req_header, lim_header, percent_lim_header);
        }
        printf("%-8s  %"req_width"s  %"percent_req_width"s  %"lim_width"s  %"percent_lim_width"s\n" , "CPU", req_cpu_text, percent_req_cpu_text, lim_cpu_text, percent_lim_cpu_text);
        printf("%-8s  %"req_width"s  %"percent_req_width"s  %"lim_width"s  %"percent_lim_width"s\n", "Memory", req_mem_text, percent_req_mem_text, lim_mem_text, percent_lim_mem_text);
    }

    if ( output == "json" ) {
        quotes=( units == "full")? "":"\""
        printf("{");
        printf("\"CPU\": {");
        printf("\"requested\": "quotes"%s"quotes",", req_cpu_text);
        printf("\"limits\": "quotes"%s"quotes",", lim_cpu_text);
        printf("},");

        printf("\"Memory\": {");
        printf("\"requested\": "quotes"%s"quotes",", req_mem_text);
        printf("\"limits\": "quotes"%s"quotes",", lim_mem_text);
        printf("}");
    }
  }
  '
  awk -v output="${UTILIZATION_OUTPUT}" \
      -v units="${UTILIZATION_UNITS}" \
      -v headers="${UTILIZATION_HEADERS}" \
      "${UTILIZATION_AWK_FN}${awkcmd}" <(get_node_data) <(get_pod_data)
}

#Get namespace utilization
namespace_utilization() {
  awkcmd='BEGIN {FS="\t"};
  namespaces[$1];

  #cpu requests
  $3 ~ /[0-9]$/ { req_cpu[$1]+=$3*1000; };
  $3 ~ /m?$/    { req_cpu[$1]+=$3; };

  #memory requests
  $4 ~ /m$/         { req_mem[$1]+=$4/1000; };
  $4 ~ /[kK](i)?$/  { req_mem[$1]+=$4*1024; };
  $4 ~ /M(i)?$/     { req_mem[$1]+=$4*1048576; };
  $4 ~ /[gG](i)?$/  { req_mem[$1]+=$4*1073741824; };
  $4 ~ /[tT](i)?$/  { req_mem[$1]+=$4*1099511627776; };

  #cpu limits
  $5 ~ /[0-9]$/ { lim_cpu[$1]+=$5*1000; };
  $5 ~ /m?$/    { lim_cpu[$1]+=$5; };

  #memory limits
  $6 ~ /m$/         { lim_mem[$1]+=$6/1000; next };
  $6 ~ /[kK](i)?$/  { lim_mem[$1]+=$6*1024; next };
  $6 ~ /M(i)?$/     { lim_mem[$1]+=$6*1048576; next };
  $6 ~ /[gG](i)?$/  { lim_mem[$1]+=$6*1073741824; next };
  $6 ~ /[tT](i)?$/  { lim_mem[$1]+=$6*1099511627776; next };

  END {
    total_records=0;
    for (namespace in namespaces) {
        total_records++;
        nsindex[total_records]=namespace;
        if (longest_namespace_len < length(namespace)) longest_namespace_len = length(namespace)
    }
    if (longest_namespace_len < 9 ) longest_namespace_len = 9
    # sort namespaces alphabetically
    a_sort(nsindex)
    if ( output == "text" ) {
      req_cpu_header=prettify("CPU Requests", "Req")
      req_mem_header=prettify("Memory Requests", "Req")
      lim_cpu_header=prettify("CPU Limits", "Lim")
      lim_mem_header=prettify("Memory Limits", "Lim")

      req_cpu_width=length(req_cpu_header)
      req_mem_width=length(req_mem_header)
      lim_cpu_width=length(lim_cpu_header)
      lim_mem_width=length(lim_mem_header)

      for (z = 1; z in nsindex; z++) {
        req_cpu_text[z]=prettify(req_cpu[nsindex[z]], cpu_pretty(req_cpu[nsindex[z]]))
        req_mem_text[z]=prettify(sprintf("%.0f",req_mem[nsindex[z]]), mem_pretty(req_mem[nsindex[z]]))
        lim_cpu_text[z]=prettify(lim_cpu[nsindex[z]], cpu_pretty(lim_cpu[nsindex[z]]))
        lim_mem_text[z]=prettify(sprintf("%.0f",lim_mem[nsindex[z]]), mem_pretty(lim_mem[nsindex[z]]))

        req_cpu_width=(req_cpu_width < length(req_cpu_text[z]))? length(req_cpu_text[z]): req_cpu_width
        req_mem_width=(req_mem_width < length(req_mem_text[z]))? length(req_mem_text[z]): req_mem_width
        lim_cpu_width=(lim_cpu_width < length(lim_cpu_text[z]))? length(lim_cpu_text[z]): lim_cpu_width
        lim_mem_width=(lim_mem_width < length(lim_mem_text[z]))? length(lim_mem_text[z]): lim_mem_width
      }
      if ( headers == "true" ) {
          if ( units == "human" ) {
              printf("%-"longest_namespace_len"s  %-"req_cpu_width"s  %"lim_cpu_width"s  %-"req_mem_width"s  %"lim_mem_width"s\n", "", "CPU", "", "Memory", "")
          }
          printf("%-"longest_namespace_len"s  %"req_cpu_width"s  %"lim_cpu_width"s  %"req_mem_width"s  %"lim_mem_width"s\n", "Namespace", req_cpu_header, lim_cpu_header, req_mem_header, lim_mem_header)
      }
      for (z = 1; z in nsindex; z++) {
          printf("%-"longest_namespace_len"s  %"req_cpu_width"s  %"lim_cpu_width"s  %"req_mem_width"s  %"lim_mem_width"s\n", nsindex[z], req_cpu_text[z], lim_cpu_text[z], req_mem_text[z], lim_mem_text[z])
      }
    }
    if ( output == "json" ) {
      printf("{");
      for (z = 1; z in nsindex; z++) {
        printf("\"%s\": {", nsindex[z]);
        printf("\"CPU\": {");
        printf("\"requested\": %s,", (req_cpu[nsindex[z]]=="" ? "0" : req_cpu[nsindex[z]]));
        printf("\"limits\": %s", (lim_cpu[nsindex[z]]=="" ? "0" : lim_cpu[nsindex[z]]));
        printf("},");
        printf("\"Memory\": {");
        printf("\"requested\": %s,", (req_mem[nsindex[z]]=="" ? "0" : req_mem[nsindex[z]]));
        printf("\"limits\": %s", (lim_mem[nsindex[z]]=="" ? "0" : lim_mem[nsindex[z]]));
        printf("}");
        separator = (z < total_records ? "," : "");
        printf("}%s",separator);
      }
      printf("}");
    }
  }
  '
  awk -v output="${UTILIZATION_OUTPUT}" \
      -v units="${UTILIZATION_UNITS}" \
      -v headers="${UTILIZATION_HEADERS}" \
      "${UTILIZATION_AWK_FN}${awkcmd}" <(get_pod_data)
}

#Get node utilization
node_utilization() {
  awkcmd='BEGIN {FS="\t"};
  NR==FNR { nodes[$1]; }

  NR==FNR && $2 ~ /[0-9]$/ { alloc_cpu[$1]+=$2*1000; };
  NR==FNR && $2 ~ /m?$/    { alloc_cpu[$1]+=$2; };
  NR==FNR && $3 ~ /Ki?$/   { alloc_mem[$1]+=$3*1024; next };

  #cpu requests
  $3 ~ /[0-9]$/ { req_cpu[$2]+=$3*1000; };
  $3 ~ /m$/    { req_cpu[$2]+=$3; };

  #memory requests
  $4 ~ /m$/         { req_mem[$2]+=$4/1000; };
  $4 ~ /[kK](i)?$/  { req_mem[$2]+=$4*1024; };
  $4 ~ /M(i)?$/     { req_mem[$2]+=$4*1048576; };
  $4 ~ /[gG](i)?$/  { req_mem[$2]+=$4*1073741824; };
  $4 ~ /[tT](i)?$/  { req_mem[$2]+=$4*1099511627776; };

  #cpu limits
  $5 ~ /[0-9]$/ { lim_cpu[$2]+=$5*1000; };
  $5 ~ /m$/    { lim_cpu[$2]+=$5; };

  #memory limits
  $6 ~ /m$/         { lim_mem[$2]+=$6/1000; next };
  $6 ~ /[kK](i)?$/  { lim_mem[$2]+=$6*1024; next };
  $6 ~ /M(i)?$/     { lim_mem[$2]+=$6*1048576; next };
  $6 ~ /[gG](i)?$/  { lim_mem[$2]+=$6*1073741824; next };
  $6 ~ /[tT](i)?$/  { lim_mem[$2]+=$6*1099511627776; next };

  END {
    total_records=0;
    for (node in nodes) {
        total_records++;
        noindex[total_records]=node;
        if (longest_node_len < length(node)) longest_node_len = length(node)
    }
    if (longest_node_len < 9 ) longest_node_len = 9
    # sort nodes alphabetically
    a_sort(noindex)
    if ( output == "text" ) {
      req_cpu_header=prettify("Requests", "Req")
      percent_req_cpu_header=prettify("%Requests", "%R")
      req_mem_header=prettify("Requests", "Req")
      percent_req_mem_header=prettify("%Requests", "%R")
      lim_cpu_header=prettify("Limits", "Lim")
      percent_lim_cpu_header=prettify("%Limits", "%L")
      lim_mem_header=prettify("Limits", "Lim")
      percent_lim_mem_header=prettify("%Limits", "%L")

      #Calculate header width
      req_cpu_width=length(req_cpu_header)
      percent_req_cpu_width=length(percent_req_cpu_header)
      if (percent_req_cpu_width < 3 ) percent_req_cpu_width = 3

      req_mem_width=length(req_mem_header)
      percent_req_mem_width=length(percent_req_mem_header)

      if (percent_req_mem_width < 3 ) percent_req_mem_width = 3
      lim_cpu_width=length(lim_cpu_header)
      lim_mem_width=length(lim_mem_header)
      percent_lim_cpu_width=length(percent_lim_cpu_header)
      if (percent_lim_cpu_width < 3 ) percent_lim_cpu_width = 4
      req_mem_width=length(req_mem_header)
      percent_lim_mem_width=length(percent_lim_mem_header)
      if (percent_lim_mem_width < 3 ) percent_lim_mem_width = 4
      for (z = 1; z in noindex; z++) {
        req_cpu_text[z]=prettify(req_cpu[noindex[z]], cpu_pretty(req_cpu[noindex[z]]))
        req_mem_text[z]=prettify(sprintf("%.0f",req_mem[noindex[z]]), mem_pretty(req_mem[noindex[z]]))
        lim_cpu_text[z]=prettify(lim_cpu[noindex[z]], cpu_pretty(lim_cpu[noindex[z]]))
        lim_mem_text[z]=prettify(sprintf("%.0f",lim_mem[noindex[z]]), mem_pretty(lim_mem[noindex[z]]))

        percent_req_cpu_text[z]=prettify(calc_percentage(req_cpu[noindex[z]], alloc_cpu[noindex[z]]), sprintf("%s%%", calc_percentage(req_cpu[noindex[z]], alloc_cpu[noindex[z]])))
        percent_req_mem_text[z]=prettify(calc_percentage(req_mem[noindex[z]], alloc_mem[noindex[z]]), sprintf("%s%%", calc_percentage(req_mem[noindex[z]], alloc_mem[noindex[z]])))

        req_cpu_width=(req_cpu_width < length(req_cpu_text[z]))? length(req_cpu_text[z]): req_cpu_width
        req_mem_width=(req_mem_width < length(req_mem_text[z]))? length(req_mem_text[z]): req_mem_width
        lim_cpu_width=(lim_cpu_width < length(lim_cpu_text[z]))? length(lim_cpu_text[z]): lim_cpu_width
        lim_mem_width=(lim_mem_width < length(lim_mem_text[z]))? length(lim_mem_text[z]): lim_mem_width

        percent_lim_cpu_text[z]=prettify(calc_percentage(lim_cpu[noindex[z]], alloc_cpu[noindex[z]]), sprintf("%s%%", calc_percentage(lim_cpu[noindex[z]], alloc_cpu[noindex[z]])))
        percent_lim_mem_text[z]=prettify(calc_percentage(lim_mem[noindex[z]], alloc_mem[noindex[z]]), sprintf("%s%%", calc_percentage(lim_mem[noindex[z]], alloc_mem[noindex[z]])))

        percent_lim_cpu_graph[z]=calc_percentage(lim_cpu[noindex[z]], alloc_cpu[noindex[z]])
        percent_lim_mem_graph[z]=calc_percentage(lim_mem[noindex[z]], alloc_mem[noindex[z]])
        percent_lim_cpu_graph_input[z]=percent_lim_cpu_graph[z]
        percent_lim_mem_graph_input[z]=percent_lim_mem_graph[z]
      }
      if ( headers == "true" ) {
        printf("CPU   : %s\n", graph(percent_lim_cpu_graph_input))
        printf("Memory: %s\n", graph(percent_lim_mem_graph_input))

        printf("%-"longest_node_len"s  ", "")
        printf("%-"req_cpu_width"s  ", "CPU")
        printf("%"percent_req_cpu_width"s  ", "")
        printf("%"lim_cpu_width"s  ", "")
        printf("%"percent_lim_cpu_width"s  ", "")
        printf("%-"req_mem_width"s  ", "Memory")
        printf("%"percent_req_mem_width"s  ", "")
        printf("%"lim_mem_width"s  ", "")
        printf("%"percent_lim_mem_width"s\n", "")

        printf("%-"longest_node_len"s  ",     "Node")
        printf("%"req_cpu_width"s  ",         req_cpu_header)
        printf("%"percent_req_cpu_width"s  ", percent_req_cpu_header)
        printf("%"lim_cpu_width"s  ",         lim_cpu_header)
        printf("%"percent_lim_cpu_width"s  ", percent_lim_cpu_header)
        printf("%"req_mem_width"s  ",         req_mem_header)
        printf("%"percent_req_mem_width"s  ", percent_req_mem_header)
        printf("%"lim_mem_width"s  ",         lim_mem_header)
        printf("%"percent_lim_mem_width"s\n", percent_lim_mem_header)
      }
      for (z = 1; z in noindex; z++) {
        printf("%-"longest_node_len"s  ",       noindex[z])
        printf("%"req_cpu_width"s  ",           req_cpu_text[z])
        printf("%"percent_req_cpu_width"s  ",   percent_req_cpu_text[z])
        printf("%"lim_cpu_width"s  ",           lim_cpu_text[z])
        printf("%"percent_lim_cpu_width"s  ", percent_lim_cpu_text[z])
        printf("%"req_mem_width"s  ",           req_mem_text[z])
        printf("%"percent_req_mem_width"s  ",   percent_req_mem_text[z])
        printf("%"lim_mem_width"s  ",           lim_mem_text[z])
        printf("%"percent_lim_mem_width"s\n", percent_lim_mem_text[z])
      }
    }

      if ( output == "json" ) {
        printf("{");

        for (z = 1; z in noindex; z++) {
          printf("\"%s\": {", noindex[z]);
          printf("\"CPU\": {");
          printf("\"requested\": %s,", (req_cpu[noindex[z]]=="" ? "0" : req_cpu[noindex[z]]));
          printf("\"limits\": %s", (lim_cpu[noindex[z]]=="" ? "0" : lim_cpu[noindex[z]]));
          printf("},");
          printf("\"Memory\": {");
          printf("\"requested\": %s,", (req_mem[noindex[z]]=="" ? "0" : req_mem[noindex[z]]));
          printf("\"limits\": %s", (lim_mem[noindex[z]]=="" ? "0" : lim_mem[noindex[z]]));
          printf("}");
          separator = (z < total_records ? "," : "");
          printf("}%s",separator);
        }
        printf("}");
      }
  }
  '
    awk -v output="${UTILIZATION_OUTPUT}" \
        -v units="${UTILIZATION_UNITS}" \
        -v headers="${UTILIZATION_HEADERS}" \
        "${UTILIZATION_AWK_FN}${awkcmd}" <(get_node_data) <(get_pod_data)
}

UTILIZATION_AWK_FN='
function graph(a){
    result=""
    min=0
    max=100
    delete overcommit

    for (n in a) {
        if (int(a[n]) > 100) {
            overcommit[n]=int(a[n])
            a[n]=100
        }
    }
    return result
}

function a_sort(ary,   q, x, z){
   for (q in ary)
   {
      x = ary[q]
      for (z = q - 1; z && ary[z] > x; z--)
      {
         ary[z + 1] = ary[z]
      }
      ary[z + 1] = x
   }
   return a_join(ary, ORS)
}

function a_join(ary, sep,   q, x, z){
   # argument order is copacetic with Ruby
   for (q = 1; q in ary; q++)
   {
      if (x)
      {
         z = z sep ary[q]
      }
      else
      {
         z = ary[q]
         x = 1
      }
   }
   return z
}

function prettify(full, human) {
  return ( units == "full" )? full : human;
}

function calc_max_width(a,b,c) {
  len1=(length(a)>length(b))? length(a) : length(b)
  return (len1>length(c))? len1 : length(c)
}

function calc_percentage(a,b){
  if ( a > 0 && b > 0 ) {
    return sprintf("%d", a * 100 / b);
  } else if ( b > 0 ) {
    return "0";
  } else {
    return "Error";
  }
}

function cpu_pretty(sum){
  if (sum < 10000) {
    ret = sprintf("%.2g",sum/1000)
  } else {
    ret = sprintf("%d",sum/1000)
  }
  return ret
}

function mem_pretty(sum){
  if (sum > 0) {
    hum[1024^4]="T";
    hum[1024^3]="G";
    hum[1024^2]="M";
    hum[1024^1]="K";
    hum[1]="";
    for (x=1024^4; x>=0; x/=1024){
      if (sum>=x) {
        if (sum/x <= 10){
          ret = sprintf("%.2g%s",sum/x,hum[x]);break;
        } else {
          ret = sprintf("%.f%s",sum/x,hum[x]);break;
        }
      }
    }
  } else {
    return "0"
  }
  return ret
}
'

while [ "$#" -gt 0 ]; do
  case "$1" in
    namespace*) UTILIZATION_SUBCOMMAND="namespaces"; shift;;
    node*) UTILIZATION_SUBCOMMAND="nodes"; shift;;
    -n|--namespace)
      if [[ $# -lt 2 ]]; then
        echo "Namespace name is required"
        exit 1
      fi
      UTILIZATION_NAMESPACE="$2";
      shift 2
      ;;
    --namespace=*)
      if [ "${1#*=}" == "" ]; then
        echo "Label selector value is required"
        exit 1
      fi
      UTILIZATION_NODE_LABEL="${1#*=}";
      shift 1
      ;;
    -l|--selector)
      if [[ $# -lt 2 ]]; then
        echo "Label selector value is required"
        exit 1
      fi
      UTILIZATION_NODE_LABEL="$2";
      shift 2
      ;;
    --selector=*)
      if [ "${1#*=}" == "" ]; then
        echo "Label selector value is required"
        exit 1
      fi
      UTILIZATION_NODE_LABEL="${1#*=}";
      shift 1
      ;;
    -o|--output)
      if [ "${2}" == "text" ] || [ "${2}" == "json" ]; then
        UTILIZATION_OUTPUT="$2";
      else
        echo "Valid value is: text, json"
        exit 1
      fi
      shift 2
      ;;
    --output=*)
      if [ "${1#*=}" == "text" ] || [ "${1#*=}" == "json" ]; then
        UTILIZATION_OUTPUT="${1#*=}";
      else
        echo "Valid value is: text, json"
        exit 1
      fi
      shift 1
      ;;
  esac
done

case ${UTILIZATION_SUBCOMMAND} in
  namespaces)
    namespace_utilization
    ;;
  nodes)
    node_utilization
    ;;
  *)
    cluster_utilization
    ;;
esac


