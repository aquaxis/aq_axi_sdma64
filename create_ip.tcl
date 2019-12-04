set PROJECT_NAME aq_axi_sdma64
set PART_NAME xc7z020clg400-1

create_project $PROJECT_NAME ./$PROJECT_NAME -part $PART_NAME -force

set FILES [list \
           ../$PROJECT_NAME/src/aq_axi_sdma64.v \
           ../$PROJECT_NAME/src/aq_axi_sdma64_ctrl.v \
           ../$PROJECT_NAME/src/aq_axi_sdma64_fifo.v \
           ../$PROJECT_NAME/src/aq_axi_sdma64_fifo_rtl.v \
           ../$PROJECT_NAME/src/aq_axi_sdma64_intreg.v \
           ../$PROJECT_NAME/src/aq_axi_sdma64_master.v \
          ]

add_files -norecurse $FILES

ipx::package_project -root_dir ../$PROJECT_NAME -vendor aquaxis.com -library aquaxis -taxonomy /UserIP

set_property core_revision 1 [ipx::current_core]

ipx::create_xgui_files [ipx::current_core]
ipx::update_checksums [ipx::current_core]
ipx::save_core [ipx::current_core]
