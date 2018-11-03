#!/usr/bin/python
# -*- coding: UTF-8 -*-
# 工程软连接,跨平台
# 

import os,sys,shutil

linkList = [#文件，软链目录，软链相对路径
	["simulator/win32/src","../../src"],
	["simulator/win32/res","../../res"],
	["simulator/win32/config.json","../../config.json"]
]
os.chdir(os.getcwd())

if __name__ == '__main__':
	for item in linkList:
		os.symlink(item[1], item[0])
# 创建软链接
# os.symlink(src, dst)