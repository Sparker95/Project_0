@echo off
PUSHD "%~dp0"
if not exist Vindicta.Altis\config\user_local_config.hpp copy Vindicta.Altis\config\user_local_config.hpp.template Vindicta.Altis\config\user_local_config.hpp
if not exist Vindicta.Enoch mklink /D /J Vindicta.Enoch Vindicta.Altis
if not exist Vindicta.cup_chernarus_A3 mklink /D /J Vindicta.cup_chernarus_A3 Vindicta.Altis
if not exist Vindicta.Malden mklink /D /J Vindicta.Malden Vindicta.Altis
if not exist Vindicta.Tembelan mklink /D /J Vindicta.Tembelan Vindicta.Altis
if not exist Vindicta.Staszow mklink /D /J Vindicta.Staszow Vindicta.Altis
if not exist Vindicta.Beketov mklink /D /J Vindicta.Beketov Vindicta.Altis
if not exist Vindicta.Takistan mklink /D /J Vindicta.Takistan Vindicta.Altis
if not exist Vindicta.gm_weferlingen_summer mklink /D /J Vindicta.gm_weferlingen_summer Vindicta.Altis
if not exist Vindicta.saralite mklink /D /J Vindicta.saralite Vindicta.Altis
call edit_altis.bat
POPD
