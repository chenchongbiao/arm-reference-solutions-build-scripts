################################################################################
#
# vector_workload
#
################################################################################

VECTOR_WORKLOAD_SITE = ${BR2_EXTERNAL_TC_TREE_PATH}/package/vector_workload
VECTOR_WORKLOAD_SITE_METHOD = local


define VECTOR_WORKLOAD_BUILD_CMDS
	$(TARGET_CC) $(@D)/vector_workload.c -o $(@D)/vector_workload -static -march=armv8-a+sve
endef

define VECTOR_WORKLOAD_INSTALL_TARGET_CMDS
	$(INSTALL) -D -m 0755 $(@D)/vector_workload  $(TARGET_DIR)/bin
endef

$(eval $(generic-package))
