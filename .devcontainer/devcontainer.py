#!/usr/bin/env python3
import os, sys, time, pwd


def get_username():
	return str(pwd.getpwuid(os.getuid())[0])


def run(cmd):
	try:
		print(cmd)
		os.system(cmd)
	except:
		pass


def apt(string, use_sudo=False):
	run("{0} apt-get update".format("sudo " if use_sudo else ""))
	run("{0} apt-get install -y {1}".format("sudo " if use_sudo else "", string))


def try_apt(string):
	try:
		apt(string, use_sudo=True)
	except:
		pass
	try:
		apt(string, use_sudo=False)
	except:
		pass


def pip(string):
	run("{0} -m pip install --upgrade {1}".format(sys.executable, string))


pip("funbelts")
import funbelts as ut

pip("when-changed xonsh[full] mystring hugg[all] sdock[all] malloy")
apt("sqlite3")
apt("inkscape")

devcontainer = os.path.join(os.path.dirname(__file__), "devcontainer.json")
for extension in ut.cmt_json(devcontainer)["customizations"]["vscode"]["extensions"]:
	run(f"code-server --install-extension {extension}")


def mitosheet_pro():
	if os.path.exists("/bin/mitosheet"):
		return

	pip("mitoinstaller")
	run("{} -m mitoinstaller upgrade".format(sys.executable))
	import json, uuid

	information = {
		"static_user_id": "",
		"mitosheet_telemetry": False,
		"mitosheet_pro": True,
		"mitosheet_enterprise": True,
		"experiment": {
			"experiment_id": "installer_communication_and_time_to_value",
			"variant": "A",
		},
		"user_json_version": 7,
		"user_salt": "",
		"user_email": "",
		"received_tours": [],
		"feedbacks": [],
		"mitosheet_current_version": "0.1.437",
		"mitosheet_last_upgraded_date": "2023-07-29",
		"mitosheet_last_fifty_usages": ["2023-07-29"],
		"feedbacks_v2": {},
		"received_checklists": {},
	}

	with open("/{0}/.mito/user.json".format(get_username), "w+") as writer:
		json.dump(information, writer)

	from glob import glob as re

	for folder in re("/usr/local/lib/python3.*"):
		try:
			from fileinput import FileInput as finput

			with finput(
				str(folder) + "/site-packages/mitoinstaller/log_utils.py",
				inplace=True,
				backup=None,
			) as writer:
				for line in writer:
					if line.strip() == "static_user_id = get_static_user_id()":
						line = line.replace(
							"get_static_user_id()", "get_static_user_id();return"
						)
					elif line.strip().startswith("analytics.write_key = "):
						line = line.replace(".write_key = ", ".write_key = None#")
					elif "user_json_is_installer_default() and" in line:
						line = line.replace(
							"user_json_is_installer_default() and", "False and "
						)
					elif "user == 'jovyan'" in line:
						line = line.replace(
							"user == 'jovyan'", "user == 'jovyan' or True"
						)
					print(line.strip())
		except:
			pass
	# create_bin('/bin/mitosheet','jupyter-lab --ip=0.0.0.0 --allow-root')
	try:
		os.remove("mito-starter-notebook.ipynb")
	except:
		pass


alias_strings = """
alias update='apt-get update;apt update;apt-get upgrade -y;apt upgrade -y;apt dist-upgrade -y;apt full-upgrade -y;apt autoremove -y;refresh'
alias mitoup='pip3 install mitoinstaller --upgrade;python3 -m mitoinstaller upgrade;'
alias refresh='hook;source ~/.bashrc'
alias vo='invoke'
alias voke='invoke'
alias attach='tmux a -t'
alias show='tmux list-sessions'
alias new='tmux new -s'
alias list='tmux list-sessions'
alias lab='jupyter lab --ip 0.0.0.0 --allow-root'
alias sync='git add .;git commit -m "Update";git push'
alias dock='python3 <(curl -sL https://rebrand.ly/pydock)'
alias dock.sh='python3 <(curl -sL https://rebrand.ly/pydock)'
alias zz='python3 <(curl -sL https://rebrand.ly/pyzz)'
alias zz.sh='python3 <(curl -sL https://rebrand.ly/pyzz)'
alias ez='python3 <(curl -sL https://rebrand.ly/pyez)'
alias ez.sh='python3 <(curl -sL https://rebrand.ly/pyez)'
alias cmtr='python3 <(curl -sL https://rebrand.ly/pycmtr)'
alias cmtr.sh='python3 <(curl -sL https://rebrand.ly/pycmtr)'
alias pyup='python3 <(curl -sL https://rebrand.ly/pyup)'
alias pyarrow='yes|rm -r /usr/local/lib/python3.8/site-packages/pyarrow*'
alias prep='mitopro;jupyterlab;vi;pyup;xonsh;'
alias fprep='ipy;xonsh;vs;pyup;vs;mitopro;jupyterlab'
alias hook='python3 <(curl -sL https://rebrand.ly/pyhook)'
alias baserust='curl -sL https://rebrand.ly/corers >> base.rs'
alias sup='python3 -m suplemon'
alias jupyterlab="jupyter lab --ip=0.0.0.0 --NotebookApp.token='' --NotebookApp.password=''"
"""

try_apt("tmux neovim curl wget p7zip-full")

run("docker pull frantzme/scalapy:lite")
for x in "pip mystring[all] hugg[all] sdock xonsh suplemon jupyter-book jupyter-lab when-changed python-minifier pandoc bython".split(
	" "
):
	pip(x)

startup = "vs_startup.sh"
try:
	os.remove(startup)
except:pass
with open(startup, "w+") as writer:
	writer.write("#STARTUPHERE")

try:
	#mitosheet_pro()
	print("")
except:
	pass

try:
	with open("~/.bashrc", "a+") as writer:
		for string in alias_strings.split():
			string = string.strip()
			if string and string != "":
				writer.write(string)
except Exception as e:
	print(e)

run("docker pull frantzme/texbuilder:2020")

if False:
	while not os.path.exists("/var/run/docker.sock"):
		print(".", end="", flush=True)
		run("/usr/local/share/docker-init.sh")
		time.sleep(1)
	run("service docker restart")