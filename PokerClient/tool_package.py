# -*- coding: utf-8 -*- 
import os
import hashlib
import time
import shutil

# 获取本文件所在目录，命令行转到当前目录
curdir = os.path.split(os.path.realpath(__file__))[0]  
os.chdir(curdir) 

# 工程类型
projectType = 0
projectList = [
    ["http://192.168.1.6:80/hotUpdate/"],           #测试服

]
# 热更文件 服务器地址
rooturl = projectList[projectType][0]

# 获取文件md5
def getFileMd5(filename):
    if not os.path.isfile(filename):
        return
    myhash = hashlib.md5()# create a md5 object
    f = open(filename,'rb')
    while True:
        b = f.read(8096)# get file content.
        if not b :
            break
        myhash.update(b)#encrypt the file
    f.close()
    return myhash.hexdigest()

# 递归文件夹，获取文件MD5
def walk(path, prefix):
    global xml
    fl = os.listdir(path) # get what we have in the dir.
    for f in fl:
        if os.path.isdir(os.path.join(path,f)): # if is a dir.
            if prefix == '':
                walk(os.path.join(path,f), f)
            else:
                walk(os.path.join(path,f), prefix + '/' + f)
        else:
            if f != 'config.luac' and not f.endswith(".manifest"):
                md5 = getFileMd5(os.path.join(path,f))
                xml += "\n\t\t\"%s\" : {\n\t\t\t\"md5\" : \"%s\"\n\t\t}, " % (prefix + '/' + f, md5) # output to the md5 value to a string in xml format.



#执行命令
def run_cmd(cmdstr):    
    print(cmdstr)  
    ret = os.system(cmdstr)  
    if ret < 0:  
        print('run_cmd result = ' + str(ret))  
        exit(0)  
    else:  
        print('run_cmd result = ' + str(ret))

def copyFile(pPath,newPath):
    for file in os.listdir(pPath):
        sourceFile = os.path.join(pPath,file)
        targetFile = os.path.join(newPath,file)
        if not os.path.exists(newPath):
            os.makedirs(newPath)
        if os.path.isfile(sourceFile):
            if not (sourceFile.find(".svn") > 0 or sourceFile.find(".DS_Store") > 0):
                # print(targetFile)
                open(targetFile, "wb").write(open(sourceFile, "rb").read()) 
        else:
            if not (sourceFile.find(".svn") > 0 or sourceFile.find(".DS_Store") > 0):
                # print(targetFile)
                if not os.path.exists(targetFile):
                    # print(targetFile)
                    os.makedirs(targetFile)
                copyFile(sourceFile,targetFile)

if __name__ == "__main__": 

    #删除out目录
    if os.path.exists(curdir +"/out"):	
        shutil.rmtree(curdir +"/out",True,None)
    if not os.path.exists(curdir +"/out"):
        os.mkdir(curdir +"/out")
    shutil.copytree('./res','out/res',False)
    # 编译lua文件成luac
    # run_cmd("cocos luacompile -s src/ -d out/version/src -e  -k WH002xHNxBYBL -b caitouSign123!@# --disable-compile")
    run_cmd("cocos luacompile -s src/ -d out/src")	
    #shutil.copytree('./res',Android_Res+'/res',False)

    # 转到out目录
    os.chdir(curdir +"/out")
    if not os.path.exists("manifest"):
        os.mkdir("manifest")
    # timeStr = time.strftime("%Y%m%d%H%M%S",time.localtime(time.time()))
    timeStr = int(time.time())
    xml = '{\
    \n\t"packageUrl" : "'+rooturl+'",\
    \n\t"remoteVersionUrl" : "'+rooturl+'version.manifest",\
    \n\t"remoteManifestUrl" : "'+rooturl+'project.manifest",\
    \n\t"version" : "%s",\
    \n\t"engineVersion" : "Cocos2d-x v3.10",\
    \n\t"assets" : {' % timeStr
    walk(os.getcwd(), '')
    xml = xml[:-2]
    xml += '\n\t},\
    \n\t"searchPaths" : [\
    \n\t]\
    \n}'

    f = open("manifest/project.manifest", "w+")
    f.write(xml)
    f.close()
    print ("generate project.manifest finish.")
	
    #generate version.manifest
    xml = '{\
    \n\t"packageUrl" : "'+rooturl+'",\
    \n\t"remoteVersionUrl" : "'+rooturl+'version.manifest",\
    \n\t"remoteManifestUrl" : "'+rooturl+'project.manifest",\
    \n\t"version" : "%s",\
    \n\t"engineVersion" : "Cocos2d-x v3.17"\n}' % timeStr
    f = open("manifest/version.manifest", "w+")
    f.write(xml)
    f.close()
    print("generate version.manifest finish.")

    copyFile("manifest","./")
    copyFile("manifest","src/version")
    copyFile("manifest",curdir+"/src/version")
    shutil.rmtree("manifest")

    # if  os.path.exists(os.getcwd() + '/' + project+'.zip'):	
    #     os.remove(os.getcwd() + '/' + project+'.zip')
    # shutil.make_archive(project,"zip",'./project')
    # print("zip finished!!!")

    # Android打包
    # run_cmd("cocos compile -p android -m release --ndk-mode release --compile-script 0 --lua-encrypt --lua-encrypt-key WH002xHNxBYBL --lua-encrypt-sign caitouSign123!@#")	
	
    print ("\n")
    print ("\n")
    print ("=======================================")
    print ("done!")
    print ("=======================================")
    print ("\n")
    print ("\n")






