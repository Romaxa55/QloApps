#!/bin/bash

# Путь к вашему проекту
PROJECT_PATH="."

# Массив с именами всех модулей
modules=(
  "bankwire"
  "blockcart"
  "blockcms"
  "blockcontact"
  "blockcontactinfos"
  "blockcurrencies"
  "blockfacebook"
  "blocklanguages"
  "blocklayered"
  "blockmanufacturer"
  "blockmyaccount"
  "blocknavigationmenu"
  "blocknewsletter"
  "blockpaymentlogo"
  "blocksocial"
  "blockspecials"
  "blocktags"
  "blockuserinfo"
  "blockviewed"
  "blockwishlist"
  "cheque"
  "cronjobs"
  "dashactivity"
  "dashavailability"
  "dashgoals"
  "dashguestcycle"
  "dashinsights"
  "dashoccupancy"
  "dashperformance"
  "dashproducts"
  "dashtrends"
  "emailgenerator"
  "feeder"
  "gapi"
  "ganalytics"
  "graphnvd3"
  "gridhtml"
  "gsitemap"
  "hotelreservationsystem"
  "mailalerts"
  "pagesnotfound"
  "producttooltip"
  "qloautoupgrade"
  "qlochannelmanagerconnector"
  "qlocleaner"
  "qlohotelreview"
  "qlopaypalcommerce"
  "qlostatsserviceproducts"
  "sekeywords"
  "socialsharing"
  "statsbestcategories"
  "statsbestcustomers"
  "statsbestproducts"
  "statsbestsuppliers"
  "statsbestvouchers"
  "statscarrier"
  "statscatalog"
  "statscheckup"
  "statsdata"
  "statsequipment"
  "statsforecast"
  "statslive"
  "statsnewsletter"
  "statsorigin"
  "statspersonalinfos"
  "statsproduct"
  "statsregistrations"
  "statssales"
  "statsvisits"
  "wkabouthotelblock"
  "wkfooteraboutblock"
  "wkfooterlangcurrencyblock"
  "wkfooternotificationblock"
  "wkfooterpaymentblock"
  "wkfooterpaymentinfoblockcontainer"
  "wkhotelfeaturesblock"
  "wkhotelfilterblock"
  "wkhotelroom"
  "wkroomsearchblock"
  "wktestimonialblock"
)

# Создание файлов перевода для каждого модуля
for module in "${modules[@]}"; do
  translation_dir="$PROJECT_PATH/modules/$module/translations"
  translation_file="$translation_dir/en.php"

  if [ ! -d "$translation_dir" ]; then
    mkdir -p "$translation_dir"
  fi

  if [ ! -f "$translation_file" ]; then
    echo "<?php

global \$_MODULE;
\$_MODULE = array();" > "$translation_file"
  fi

done
