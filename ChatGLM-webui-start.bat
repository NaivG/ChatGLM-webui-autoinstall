@echo off
::×÷ÕßNaivG£¬´úÂë½ö¹©Ñ§Ï°
title ChatGLM-webui-user
cd /d %~dp0
set lng=en
ver|findstr /r /i "°æ±¾" > NUL && set lng=cn
set ESC=
set RD=%ESC%[31m
set GN=%ESC%[32m
set YW=%ESC%[33m
set BL=%ESC%[34m
set WT=%ESC%[37m
set RN=%ESC%[0m
if "%lng%"=="cn" (
    echo %GN%[INFO] %WT% ¼ì²â³ÌÐòÔËÐÐÊ±...
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
    echo %GN%[INFO] %WT% ¸üÐÂ½Å±¾ÖÐ...
  ) else (
    echo %GN%[INFO] %WT% Updating script...
  )
git pull
if errorlevel 1 (
if "%lng%"=="cn" (
    echo %YW%[WARN] %WT% ¸üÐÂÊ§°Ü¡£
    echo         ÖØÒª£ºÇë±£³ÖÄãµÄ½Å±¾Îª×îÐÂ¡£
    echo               ×îÐÂ°æ½Å±¾È«²¿¾­¹ýÎÈ¶¨²âÊÔ£¬²¢ÇÒÓµÓÐÐÂ¹¦ÄÜ¡£
  ) else (
    echo %YW%[WARN] %WT% Update failed.
  )
ping -n 3 127.1>nul
) else (
if "%lng%"=="cn" (
    echo %GN%[INFO] %WT% ¸üÐÂ³É¹¦¡£
  ) else (
    echo %GN%[INFO] %WT% Update successful.
  )
)
if not exist installed.ini goto :firstrun
if "%lng%"=="cn" (
    echo %GN%[INFO] %WT% ¼ì²âÆô¶¯²ÎÊý...
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
    echo %GN%[INFO] %WT% ¼ì²âÍêÕûÐÔ...
  ) else (
    echo %GN%[INFO] %WT% Check program integrity...
  )
if not exist webui.py set errcode=0xA001 missing file error & goto :err
if "%method%"=="1" set ARGS=
if "%method%"=="2" set ARGS=--precision int8
if "%method%"=="3" set ARGS=--precision int4
if "%method%"=="4" set ARGS=--precision int4 --cpu
if "%lng%"=="cn" (
    echo %GN%[INFO] %WT% ³¢ÊÔÆô¶¯ÖÐ...
  ) else (
    echo %GN%[INFO] %WT% launching...
  )

::::::::::::::::::::::::::::::::::::::::::::::::Æô¶¯²ÎÊý:::::::::::::::::::::::::::::::::::::::::::::::::
set COMMANDLINE_ARGS=%ARGS% --model-path %model% --listen
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

python webui.py %COMMANDLINE_ARGS%
if errorlevel 1 set errcode=0x0101 running error & goto :runerr
goto :end

:runerr
if "%lng%"=="cn" (
    echo %RD%[ERROR] %WT% ·¢Éú´íÎó¡£
    echo %RD%[ERROR] %WT% ´íÎó´úÂë£º%errcode%
    echo %GN%[INFO] %WT% ÊÇ·ñ³¢ÊÔ¸ü¸Ä²ÎÊý£¿[Y,N]
  ) else (
    echo %RD%[ERROR] %WT% An error occurred.
    echo %RD%[ERROR] %WT% Error code£º%errcode%
    echo %GN%[INFO] %WT% Attempt to change COMMANDLINE_ARGS?[Y,N]
  )
    choice -n -c yn >nul
        if errorlevel == 2 goto :end
        if errorlevel == 1 (
	cd ..
	goto :changeargs
	)
goto :end

:installpy
md software
if "%lng%"=="cn" (
    echo %GN%[INFO] %WT% ÕýÔÚÏÂÔØpython...
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
    echo %GN%[INFO] %WT% ÕýÔÚ°²×°python...
    echo %YW%[WARN] %WT% ÇëµÈ´ý°²×°Íê³ÉºóÖØÐÂ´ò¿ª³ÌÐò¡£
    echo %YW%[WARN] %WT% Èô°²×°³ÌÐòÎ´ÔËÐÐ£¬´ó¸ÅÂÊÎªÏÂÔØÊ§°Ü£¬ÇëÖØÐÂ´ò¿ª³ÌÐò¡£
  ) else (
    echo %GN%[INFO] %WT% Installing python...
    echo %YW%[WARN] %WT% Please wait for the installation to complete and reopen the program.
    echo %YW%[WARN] %WT% If the installation program is not running, the likely rate is that the download failed. Please reopen the program.
  )
software\python-installer.exe /passive AppendPath=1 PrependPath=1 InstallAllUsers=1
echo °´ÈÎÒâ¼üÍË³ö¡£
pause>nul
exit

:installgit
md software
if "%lng%"=="cn" (
    echo %GN%[INFO] %WT% ÕýÔÚÏÂÔØgit...
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
    echo %GN%[INFO] %WT% ÕýÔÚ°²×°git...
    echo %YW%[WARN] %WT% ÇëµÈ´ý°²×°Íê³ÉºóÖØÐÂ´ò¿ª³ÌÐò¡£
    echo %YW%[WARN] %WT% Èô°²×°³ÌÐòÎ´ÔËÐÐ£¬´ó¸ÅÂÊÎªÏÂÔØÊ§°Ü£¬ÇëÖØÐÂ´ò¿ª³ÌÐò¡£
  ) else (
    echo %GN%[INFO] %WT% Installing git...
    echo %YW%[WARN] %WT% Please wait for the installation to complete and reopen the program.
    echo %YW%[WARN] %WT% If the installation program is not running, the likely rate is that the download failed. Please reopen the program.
  )
software\git-installer.exe /SILENT /NORESTART
echo °´ÈÎÒâ¼üÍË³ö¡£
pause>nul
exit

:installgcc
md software
if "%lng%"=="cn" (
    echo %GN%[INFO] %WT% ÕýÔÚÏÂÔØgcc...
  ) else (
    echo %GN%[INFO] %WT% Downloading gcc...
  )
if exist software\gcc-installer.exe (
    if not exist software\gcc-installer.exe.aria2 (
       del /q software\gcc-installer.exe
    )
  )
aria2c.exe --max-connection-per-server=16 --min-split-size=1M --dir software --out gcc-installer.exe https://nchc.dl.sourceforge.net/project/tdm-gcc/TDM-GCC%%20Installer/tdm64-gcc-5.1.0-2.exe
if "%lng%"=="cn" (
    echo %GN%[INFO] %WT% ÕýÔÚ°²×°gcc...
    echo %YW%[WARN] %WT% °²×°Íê³ÉºóÖØÐÂ´ò¿ª³ÌÐò¡£
    echo %YW%[WARN] %WT% °²×°Ê±Çë¹´Ñ¡OpenMP¡£
    echo %YW%[WARN] %WT% Èô°²×°³ÌÐòÎ´ÔËÐÐ£¬´ó¸ÅÂÊÎªÏÂÔØÊ§°Ü£¬ÇëÖØÐÂ´ò¿ª³ÌÐò¡£
  ) else (
    echo %GN%[INFO] %WT% Installing gcc...
    echo %YW%[WARN] %WT% Complete the installation and reopen the program.
    echo %YW%[WARN] %WT% Before install,check OpenMP in gcc sort.
    echo %YW%[WARN] %WT% If the installation program is not running, the likely rate is that the download failed. Please reopen the program.
  )
software\gcc-installer.exe
echo °´ÈÎÒâ¼üÍË³ö¡£
pause>nul
exit

:update
if "%lng%"=="cn" (
    echo %GN%[INFO] %WT% ³¢ÊÔ¸üÐÂÖÐ...
  ) else (
    echo %GN%[INFO] %WT% Updating webui...
  )
git pull
if errorlevel 1 (
   echo %RD%[ERROR] %WT% ¸üÐÂÊ§°Ü¡£ 
   set errcode=0x0201 update error
   goto :err
)
echo %GN%[INFO] %WT% ¸üÐÂ³É¹¦¡£
if "%2"=="-exit" (
   echo %GN%[INFO] %WT% Òò´æÔÚ²ÎÊý -exit ¶øÍË³ö³ÌÐò¡£
   goto :end
)
goto :start

:firstrun
echo %GN%[INFO] %WT% ¼ì²â°²×°Ìõ¼þ...
pip --version
if errorlevel 1 set errcode=0x1001 missing pip error & goto :err
python --version|findstr /r /i "3.11" > NUL && echo %YW%[WARN] %WT% ÄãµÄpython¿ÉÄÜ²»¼æÈÝpytorch£¬ÇëÐ¶ÔØºóÖØÐÂ´ò¿ª³ÌÐò¡£
if "%lng%"=="cn" (
    echo %GN%[INFO] %WT% ÇëÑ¡ÔñÏÔ¿¨°æ±¾£¨°æ±¾²»»¥Í¨£©
    echo       NVIDIA£¨CUDA11.6»ò11.7£©Ñ¡Ôña£¬CPUÑ¡Ôñb
  ) else (
    echo %GN%[INFO] %WT% Choose gfx card version.
    echo       A to NVIDIA[CUDA11.6 or 11.7],B to CPU
  )
    choice -n -c ab >nul
        if errorlevel == 2 (
          echo %GN%[INFO] %WT% ÒÑÑ¡ÔñCPU°æ±¾¡£
          set TORCHVER=CPU
		  goto :choosenext
        )
        if errorlevel == 1 (
          echo %GN%[INFO] %WT% ÒÑÑ¡ÔñNVIDIA£¨CUDA£©°æ±¾¡£
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
echo %GN%[INFO] %WT% ¸üÐÂpip,setuptools...
python -m pip install --upgrade pip setuptools -i https://pypi.tuna.tsinghua.edu.cn/simple
if errorlevel 1 set errcode=0x1011 install error & goto :err
echo %GN%[INFO] %WT% °²×°Ô­°æÒÀÀµ...
pip install -r requirements.txt -i https://pypi.tuna.tsinghua.edu.cn/simple
if errorlevel 1 set errcode=0x1001 install error & goto :err
echo %GN%[INFO] %WT% °²×°pytorch...
if "%TORCHVER%"=="NVIDIA" goto :TORCHNVIDIA
if "%TORCHVER%"=="CPU" goto :TORCHCPU
set errcode=0x1002 install error & goto :err

:TORCHNVIDIA
echo %GN%[INFO] %WT% ¼ì²âCUDA°æ±¾...
nvcc --version|findstr /r /i "11.6" > NUL && set cudaver=cu116
nvcc --version|findstr /r /i "11.7" > NUL && set cudaver=cu117
echo %GN%[INFO] %WT% CUDA°æ±¾£º%cudaver%
pip install torch==1.13.1+%cudaver% torchvision==0.14.1+%cudaver% --extra-index-url https://download.pytorch.org/whl/%cudaver%
if errorlevel 1 set errcode=0x1003 install error on %TORCHVER% & goto :err
goto :torchnext

:TORCHCPU
pip install torch torchvision -i https://pypi.tuna.tsinghua.edu.cn/simple
if errorlevel 1 set errcode=0x1003 install error on %TORCHVER% & goto :err
goto :torchnext

:torchnext
if "%lng%"=="cn" (
    echo %GN%[INFO] %WT% ÇëÑ¡ÔñÄ£ÐÍ°æ±¾£¨°æ±¾²»»¥Í¨£©
    echo       Ô­°æÑ¡Ôña£¬int4Ñ¡Ôñb£¬int4-qeÑ¡Ôñc£¬±¾µØÄ£ÐÍÎÄ¼þ¼Ð£¨·ÅÖÃÔÚChatGLM-webuiÄÚ£©Ñ¡Ôñd
    echo       ÅäÖÃ²»¸ßÇëÑ¡Ôñint4»òqe
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
          echo %GN%[INFO] %WT% ÒÑÑ¡Ôñint4-qe°æ¡£
          set MODELVER=INT4QE
		  goto :modelnext
        )
        if errorlevel == 2 (
          echo %GN%[INFO] %WT% ÒÑÑ¡Ôñint4°æ¡£
          set MODELVER=INT4
		  goto :modelnext
        )
        if errorlevel == 1 (
          echo %GN%[INFO] %WT% ÒÑÑ¡ÔñÔ­°æ¡£
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
echo %GN%[INFO] %WT% °²×°Íê³É¡£
cd ..
:changeargs
if "%lng%"=="cn" (
    echo %GN%[INFO] %WT% ÇëÑ¡ÔñÔ¤ÖÃÆô¶¯²ÎÊý
    echo       a.ÆÕÍ¨ÏÔ¿¨£¨ÎÞ²Î£©
    echo       b.ÆÕÍ¨ÏÔ¿¨£¨int8£©
    echo       c.ÆÕÍ¨ÏÔ¿¨£¨int4£©
    echo       d.½öCPU
  ) else (
    echo %GN%[INFO] %WT% Choose COMMANDLINE_ARGS
    echo       a.gfx card[none]
    echo       b.gfx card[int8]
    echo       c.gfx card[int4]
    echo       d.only CPU
  )
    choice -n -c abcd >nul
        if errorlevel == 4 (
          echo %GN%[INFO] %WT% ÒÑÑ¡Ôñ½öCPU¡£
          set method=4
          goto :argsnext
)
        if errorlevel == 3 (
          echo %GN%[INFO] %WT% ÒÑÑ¡ÔñÆÕÍ¨ÏÔ¿¨£¨int4£©¡£
          set method=3
          goto :argsnext
 )
        if errorlevel == 2 (
          echo %GN%[INFO] %WT% ÒÑÑ¡ÔñÆÕÍ¨ÏÔ¿¨£¨int8£©¡£
          set method=2
          goto :argsnext
)
        if errorlevel == 1 (
          echo %GN%[INFO] %WT% ÒÑÑ¡ÔñÆÕÍ¨ÏÔ¿¨£¨ÎÞ²Î£©¡£
          set method=1
          goto :argsnext
)
:argsnext
(
echo [INFO]
echo method=%method%
echo model=%model%)>installed.ini
if "%lng%"=="cn" (
    echo %GN%[INFO] %WT% ÊÇ·ñÏÖÔÚÆô¶¯£¿[Y,N]
  ) else (
    echo %GN%[INFO] %WT% Boot webui now?[Y,N]
  )
    choice -n -c yn >nul
        if errorlevel == 2 goto :end
        if errorlevel == 1 (
		cd ChatGLM-webui
		goto :start
		)
goto :end

:err
if "%lng%"=="cn" (
    echo %RD%[ERROR] %WT% ·¢Éú´íÎó¡£
    echo %RD%[ERROR] %WT% ´íÎó´úÂë£º%errcode%
  ) else (
    echo %RD%[ERROR] %WT% An error occurred.
    echo %RD%[ERROR] %WT% Error code£º%errcode%
  )
:end
if "%lng%"=="cn" (
    echo %GN%[INFO] %WT% ÒÑÍ£Ö¹ÔËÐÐ¡£
    echo °´ÈÎÒâ¼üÍË³ö¡£
  ) else (
    echo %GN%[INFO] %WT% Stopped.
    echo Press any key to exit.
  )
pause>nul