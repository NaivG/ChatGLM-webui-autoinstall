@echo off
::作者NaivG，代码仅供学习
title ChatGLM-webui-user
cd /d %~dp0
set lng=en
ver|findstr /r /i "版本" > NUL && set lng=cn
set ESC=
set RD=%ESC%[31m
set GN=%ESC%[32m
set YW=%ESC%[33m
set BL=%ESC%[34m
set WT=%ESC%[37m
set RN=%ESC%[0m
if "%lng%"=="cn" (
    echo %GN%[INFO] %WT% 检测程序运行时...
  ) else (
    echo %GN%[INFO] %WT% Check program runtime...
  )
python --version
if errorlevel 1 goto :installpy
git --version
if errorlevel 1 goto :installgit
gcc --version
if errorlevel 1 goto :installgcc
if "%lng%"=="cn" (
    echo %GN%[INFO] %WT% 更新脚本中...
  ) else (
    echo %GN%[INFO] %WT% Updating script...
  )
git pull
if errorlevel 1 (
if "%lng%"=="cn" (
    echo %YW%[WARN] %WT% 更新失败。
    echo         重要：请保持你的脚本为最新。
    echo               最新版脚本全部经过稳定测试，并且拥有新功能。
  ) else (
    echo %YW%[WARN] %WT% Update failed.
  )
ping -n 3 127.1>nul
) else (
if "%lng%"=="cn" (
    echo %GN%[INFO] %WT% 更新成功。
  ) else (
    echo %GN%[INFO] %WT% Update successful.
  )
)
if "%lng%"=="cn" (
    echo %GN%[INFO] %WT% 启用python venv...
  ) else (
    echo %GN%[INFO] %WT% Activating python venv...
  )
if not exist venv\Scripts\activate.bat python -m venv venv
call venv\Scripts\activate.bat

if not exist installed.ini goto :firstrun
if "%lng%"=="cn" (
    echo %GN%[INFO] %WT% 检测启动参数...
  ) else (
    echo %GN%[INFO] %WT% Checking COMMANDLINE_ARGS...
  )
for /f "tokens=1,* delims==" %%a in ('findstr "method=" installed.ini') do (set method=%%b)
if "%method%" neq "1" (if "%method%" neq "2" (if "%method%" neq "3" (if "%method%" neq "4" (goto :changeargs))))
for /f "tokens=1,* delims==" %%a in ('findstr "model=" installed.ini') do (set model=%%b)

cd ChatGLM-webui
if "%1"=="-update" goto :update

:start
if "%lng%"=="cn" (
    echo %GN%[INFO] %WT% 检测完整性...
  ) else (
    echo %GN%[INFO] %WT% Check program integrity...
  )
if not exist webui.py set errcode=0xA001 missing file error & goto :err
if "%method%"=="1" set ARGS=
if "%method%"=="2" set ARGS=--precision int8
if "%method%"=="3" set ARGS=--precision int4
if "%method%"=="4" set ARGS=--precision int4 --cpu
if "%lng%"=="cn" (
    echo %GN%[INFO] %WT% 尝试启动中...
  ) else (
    echo %GN%[INFO] %WT% launching...
  )

::::::::::::::::::::::::::::::::::::::::::::::::启动参数:::::::::::::::::::::::::::::::::::::::::::::::::
set COMMANDLINE_ARGS=%ARGS% --model-path %model% --listen
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

python webui.py %COMMANDLINE_ARGS%
if errorlevel 1 set errcode=0x0101 running error & goto :runerr
cd ..
goto :end

:runerr
if "%lng%"=="cn" (
    echo %RD%[ERROR] %WT% 发生错误。
    echo %RD%[ERROR] %WT% 错误代码：%errcode%
    echo %GN%[INFO] %WT% 是否尝试更改参数？[Y,N]
  ) else (
    echo %RD%[ERROR] %WT% An error occurred.
    echo %RD%[ERROR] %WT% Error code：%errcode%
    echo %GN%[INFO] %WT% Attempt to change COMMANDLINE_ARGS?[Y,N]
  )
    choice -n -c yn >nul
        if errorlevel == 2 (
	cd ..
	goto :end
	)
        if errorlevel == 1 (
	cd ..
	goto :changeargs
	)
goto :end

:installpy
md software
if "%lng%"=="cn" (
    echo %GN%[INFO] %WT% 正在下载python...
  ) else (
    echo %GN%[INFO] %WT% Downloading python...
  )
if exist software\python-installer.exe (
    if not exist software\python-installer.exe.aria2 (
       del /q software\python-installer.exe
    )
  )
aria2c.exe --max-connection-per-server=16 --min-split-size=1M --dir software --out python-installer.exe https://www.python.org/ftp/python/3.10.8/python-3.10.8-amd64.exe
if "%lng%"=="cn" (
    echo %GN%[INFO] %WT% 正在安装python...
    echo %YW%[WARN] %WT% 请等待安装完成后重新打开程序。
    echo %YW%[WARN] %WT% 若安装程序未运行，大概率为下载失败，请重新打开程序。
  ) else (
    echo %GN%[INFO] %WT% Installing python...
    echo %YW%[WARN] %WT% Please wait for the installation to complete and reopen the program.
    echo %YW%[WARN] %WT% If the installation program is not running, the likely rate is that the download failed. Please reopen the program.
  )
software\python-installer.exe /passive AppendPath=1 PrependPath=1 InstallAllUsers=1
echo 按任意键退出。
pause>nul
exit

:installgit
md software
if "%lng%"=="cn" (
    echo %GN%[INFO] %WT% 正在下载git...
  ) else (
    echo %GN%[INFO] %WT% Downloading git...
  )
if exist software\git-installer.exe (
    if not exist software\git-installer.exe.aria2 (
       del /q software\git-installer.exe
    )
  )
aria2c.exe --max-connection-per-server=16 --min-split-size=1M --dir software --out git-installer.exe https://ghproxy.com/https://github.com/git-for-windows/git/releases/download/v2.39.0.windows.1/Git-2.39.0-64-bit.exe
if "%lng%"=="cn" (
    echo %GN%[INFO] %WT% 正在安装git...
    echo %YW%[WARN] %WT% 请等待安装完成后重新打开程序。
    echo %YW%[WARN] %WT% 若安装程序未运行，大概率为下载失败，请重新打开程序。
  ) else (
    echo %GN%[INFO] %WT% Installing git...
    echo %YW%[WARN] %WT% Please wait for the installation to complete and reopen the program.
    echo %YW%[WARN] %WT% If the installation program is not running, the likely rate is that the download failed. Please reopen the program.
  )
software\git-installer.exe /SILENT /NORESTART
echo 按任意键退出。
pause>nul
exit

:installgcc
md software
if "%lng%"=="cn" (
    echo %GN%[INFO] %WT% 正在下载gcc...
  ) else (
    echo %GN%[INFO] %WT% Downloading gcc...
  )
if exist software\gcc.7z (
    if not exist software\gcc.7z.aria2 (
       del /q software\gcc.7z
    )
  )
aria2c.exe --max-connection-per-server=16 --min-split-size=1M --dir software --out gcc-installer.exe https://nuwen.net/files/mingw/mingw-18.0-without-git.exe
if "%lng%"=="cn" (
    echo %GN%[INFO] %WT% 正在安装gcc...
    echo %YW%[WARN] %WT% 安装完成后重新打开程序。
  ) else (
    echo %GN%[INFO] %WT% Installing gcc...
    echo %YW%[WARN] %WT% Complete the installation and reopen the program.
  )
7z\7z x software\gcc-installer.exe
echo %YW%[WARN] %WT% 杀软报错请同意。
setx PATH "%PATH%;%~dp0MinGW\bin"
set X_MEOW=%~dp0MinGW\include;%~dp0MinGW\include\freetype2
if defined C_INCLUDE_PATH (setx C_INCLUDE_PATH "%X_MEOW%;%C_INCLUDE_PATH%") else (setx C_INCLUDE_PATH "%X_MEOW%")
if defined CPLUS_INCLUDE_PATH (setx CPLUS_INCLUDE_PATH "%X_MEOW%;%CPLUS_INCLUDE_PATH%") else (setx CPLUS_INCLUDE_PATH "%X_MEOW%")
set X_MEOW=
echo 按任意键退出。
pause>nul
exit

:update
if "%lng%"=="cn" (
    echo %GN%[INFO] %WT% 尝试更新中...
  ) else (
    echo %GN%[INFO] %WT% Updating webui...
  )
git pull
if errorlevel 1 (
   echo %RD%[ERROR] %WT% 更新失败。 
   set errcode=0x0201 update error
   goto :err
)
echo %GN%[INFO] %WT% 更新成功。
if "%2"=="-exit" (
   echo %GN%[INFO] %WT% 因存在参数 -exit 而退出程序。
   goto :end
)
goto :start

:firstrun
echo %GN%[INFO] %WT% 检测安装条件...
pip --version
if errorlevel 1 set errcode=0x1001 missing pip error & goto :err
python --version|findstr /r /i "3.11" > NUL && echo %YW%[WARN] %WT% 你的python可能不兼容pytorch，请卸载后重新打开程序。
if "%lng%"=="cn" (
    echo %GN%[INFO] %WT% 请选择显卡版本（版本不互通）
    echo       NVIDIA（CUDA11.6或11.7）选择a，CPU选择b
  ) else (
    echo %GN%[INFO] %WT% Choose gfx card version.
    echo       A to NVIDIA[CUDA11.6 or 11.7],B to CPU
  )
    choice -n -c ab >nul
        if errorlevel == 2 (
          echo %GN%[INFO] %WT% 已选择CPU版本。
          set TORCHVER=CPU
		  goto :choosenext
        )
        if errorlevel == 1 (
          echo %GN%[INFO] %WT% 已选择NVIDIA（CUDA）版本。
          set TORCHVER=NVIDIA
		  goto :choosenext
		  )
:choosenext
echo %GN%[INFO] %WT% pulling ChatGLM-webui[1/2]...
git clone https://github.com/Akegarasu/ChatGLM-webui.git
if errorlevel 1 (
echo %GN%[INFO] %WT% pulling ChatGLM-webui[2/2]...
git clone https://ghproxy.com/https://github.com/Akegarasu/ChatGLM-webui.git
)
if not exist .\ChatGLM-webui\webui.py set errcode=0xA001 missing file error & goto :err
cd ChatGLM-webui
echo %GN%[INFO] %WT% 更新pip,setuptools...
python -m pip install --upgrade pip setuptools -i https://pypi.tuna.tsinghua.edu.cn/simple
if errorlevel 1 set errcode=0x1011 install error & goto :err
echo %GN%[INFO] %WT% 安装pytorch...
if "%TORCHVER%"=="NVIDIA" goto :TORCHNVIDIA
if "%TORCHVER%"=="CPU" goto :TORCHCPU
set errcode=0x1002 install error & goto :err

:TORCHNVIDIA
echo %GN%[INFO] %WT% 检测CUDA版本...
nvcc --version|findstr /r /i "11.6" > NUL && set cudaver=cu116
nvcc --version|findstr /r /i "11.7" > NUL && set cudaver=cu117
echo %GN%[INFO] %WT% CUDA版本：%cudaver%
pip install torch==1.13.1+%cudaver% torchvision==0.14.1+%cudaver% --extra-index-url https://download.pytorch.org/whl/%cudaver%
if errorlevel 1 set errcode=0x1003 install error on %TORCHVER% & goto :err
goto :torchnext

:TORCHCPU
pip install torch torchvision -i https://pypi.tuna.tsinghua.edu.cn/simple
if errorlevel 1 set errcode=0x1003 install error on %TORCHVER% & goto :err
goto :torchnext

:torchnext
echo %GN%[INFO] %WT% 安装原版依赖...
pip install -r requirements.txt -i https://pypi.tuna.tsinghua.edu.cn/simple
if errorlevel 1 set errcode=0x1001 install error & goto :err
if "%lng%"=="cn" (
    echo %GN%[INFO] %WT% 请选择模型版本（版本不互通）
    echo       原版选择a，int4选择b，int4-qe选择c，本地模型文件夹（放置在ChatGLM-webui内）选择d
    echo       配置不高请选择int4或qe
  ) else (
    echo %GN%[INFO] %WT% Choose model version.
    echo       A to normal,B to int4,C to int4-qe,D to local model[put in ChatGLM-webui]
    echo       if your computer have less than 16G RAM or 8G VRAM, you must choose int4 or below. 
  )
    choice -n -c abcd >nul
        if errorlevel == 4 (
          set /p model=type model name:
		  goto :done
        )   
        if errorlevel == 3 (
          echo %GN%[INFO] %WT% 已选择int4-qe版。
          set MODELVER=INT4QE
		  goto :modelnext
        )
        if errorlevel == 2 (
          echo %GN%[INFO] %WT% 已选择int4版。
          set MODELVER=INT4
		  goto :modelnext
        )
        if errorlevel == 1 (
          echo %GN%[INFO] %WT% 已选择原版。
          set MODELVER=N
		  goto :modelnext
		  )
:modelnext
echo %GN%[INFO] %WT% Download model...
if "%MODELVER%"=="INT4QE" goto :MODELINT4QE
if "%MODELVER%"=="INT4" goto :MODELINT4
if "%MODELVER%"=="N" goto :MODELN
set errcode=0x1004 install error & goto :err

:MODELINT4QE
git lfs install
if errorlevel 1 set errcode=0x1005 install error on %MODELVER% & goto :err
git clone https://huggingface.co/THUDM/chatglm-6b-int4-qe
if errorlevel 1 set errcode=0x1005 install error on %MODELVER% & goto :err
set model=chatglm-6b-int4-qe
goto :done

:MODELINT4
git lfs install
if errorlevel 1 set errcode=0x1005 install error on %MODELVER% & goto :err
git clone https://huggingface.co/THUDM/chatglm-6b-int4
if errorlevel 1 set errcode=0x1005 install error on %MODELVER% & goto :err
set model=chatglm-6b-int4
goto :done

:MODELN
git lfs install
if errorlevel 1 set errcode=0x1005 install error on %MODELVER% & goto :err
git clone https://huggingface.co/THUDM/chatglm-6b
if errorlevel 1 set errcode=0x1005 install error on %MODELVER% & goto :err
set model=chatglm-6b
goto :done

:done
echo %GN%[INFO] %WT% 安装完成。
cd ..
:changeargs
if "%lng%"=="cn" (
    echo %GN%[INFO] %WT% 请选择预置启动参数
    echo       a.普通显卡（无参）
    echo       b.普通显卡（int8）
    echo       c.普通显卡（int4）
    echo       d.仅CPU
  ) else (
    echo %GN%[INFO] %WT% Choose COMMANDLINE_ARGS
    echo       a.gfx card[none]
    echo       b.gfx card[int8]
    echo       c.gfx card[int4]
    echo       d.only CPU
  )
    choice -n -c abcd >nul
        if errorlevel == 4 (
          echo %GN%[INFO] %WT% 已选择仅CPU。
          set method=4
          goto :argsnext
)
        if errorlevel == 3 (
          echo %GN%[INFO] %WT% 已选择普通显卡（int4）。
          set method=3
          goto :argsnext
 )
        if errorlevel == 2 (
          echo %GN%[INFO] %WT% 已选择普通显卡（int8）。
          set method=2
          goto :argsnext
)
        if errorlevel == 1 (
          echo %GN%[INFO] %WT% 已选择普通显卡（无参）。
          set method=1
          goto :argsnext
)
:argsnext
(
echo [INFO]
echo method=%method%
echo model=%model%)>installed.ini
if "%lng%"=="cn" (
    echo %GN%[INFO] %WT% 是否现在启动？[Y,N]
  ) else (
    echo %GN%[INFO] %WT% Boot webui now?[Y,N]
  )
    choice -n -c yn >nul
        if errorlevel == 2 (
	cd ..
	goto :end
	)
        if errorlevel == 1 (
		cd ChatGLM-webui
		goto :start
		)
goto :end

:err
cd ..
if "%lng%"=="cn" (
    echo %RD%[ERROR] %WT% 发生错误。
    echo %RD%[ERROR] %WT% 错误代码：%errcode%
  ) else (
    echo %RD%[ERROR] %WT% An error occurred.
    echo %RD%[ERROR] %WT% Error code：%errcode%
  )
:end
if "%lng%"=="cn" (
    echo %GN%[INFO] %WT% 禁用python venv...
  ) else (
    echo %GN%[INFO] %WT% Deactivating python venv...
  )
if exist venv\Scripts\deactivate.bat call venv\Scripts\deactivate.bat
if "%lng%"=="cn" (
    echo %GN%[INFO] %WT% 已停止运行。
    echo 按任意键退出。
  ) else (
    echo %GN%[INFO] %WT% Stopped.
    echo Press any key to exit.
  )
pause>nul