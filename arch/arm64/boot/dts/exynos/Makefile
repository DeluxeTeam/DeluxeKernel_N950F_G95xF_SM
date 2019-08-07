# SPDX-License-Identifier: GPL-2.0
ifeq ($(CONFIG_EXYNOS_DTB_GREAT),y)
dtb-y += exynos8895-greatlte_eur_open_06.dtb
endif
ifeq ($(CONFIG_EXYNOS_DTB_DREAM2),y)
dtb-y += exynos8895-dream2lte_eur_open_10.dtb
endif
ifeq ($(CONFIG_EXYNOS_DTB_DREAM),y)
dtb-y += exynos8895-dreamlte_eur_open_10.dtb
endif

always            := $(dtb-y) $(dtbo-y)
clean-files       := *.dtb*
