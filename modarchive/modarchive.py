#! /usr/local/bin/python3
import os
import sys
import urllib
import urllib.request
import re
import time
import random

def get_page(url):
	response = urllib.request.urlopen(url)
	html = response.read()
	html = html.decode('utf-8')
	return html

def query(query_type):
	print("# modid|filename|downloads")
	m=re.compile('href="http://modarchive\\.org/data/downloads\\.php\\?moduleid=(\\d+)#([^\"]+)">Downloaded ([\\d,]+) times!', re.MULTILINE)
	for page in range(1, 26):
		html = get_page('http://modarchive.org/index.php?request=view_chart&query=%s&page=%d#mods' % (query_type, page))
		matches = m.findall(html)
		for match in matches:
			print("%s|%s|%s" % (match[0], match[1].lower(), match[2].replace(',','')))

def most_downloaded():
	query('tophits') # downloaded

def most_revered():
	query('topscore') # revered


def artists():
	print("# artistid|name")
	m=re.compile('href="member\\.php\\?(\\d+)">([^<]+)</a>', re.MULTILINE)
	for page in range(1, 40):
		url = 'http://modarchive.org/index.php?request=view_artist_roster&page=%d#mods' % page
		print("# %s" % url)
		time.sleep(random.randint(2,10))
		response = urllib.request.urlopen(url)
		html = response.read()
		html = html.decode('utf-8')
		matches = m.findall(html)
		for match in matches:
			print("%s|%s" % (match[0], match[1]))

def all_songs_by_artist(artist_id):
	html = get_page("http://modarchive.org/modules.php?%d" % artist_id)

	m=re.compile('<option value="(\\d+)" >(\\d+)</option>', re.MULTILINE)
	max_page = 1
	for page_num, _ in m.findall(html):
		max_page = max(max_page, int(page_num))

	artist_name = re.search("<h1 class='title'>(.+)'s Modules</h1>", html, re.MULTILINE)

	print("# artist=%d" % artist_id)
	print("# name=%s" % artist_name.group(1))
	print("# pages=%d" % max_page)
	sys.stdout.flush()

	m1=re.compile('href="module\\.php\\?(\\d+)" title="([^\\"]+)"', re.MULTILINE)
	m2=re.compile('Rated (\\d+) / 10</i>|(Unrated)</i>', re.MULTILINE)
	for page_no in range(1, max_page + 1):
		print("# page=%d" % page_no)
		time.sleep(random.randint(2,20))
		html = get_page("http://modarchive.org/index.php?request=view_artist_modules&query=%d&page=%d#mods" %
						(artist_id, page_no))
		for (mod_id, fileName),(score,unrated) in zip(m1.findall(html),
														m2.findall(html)):
			fileName = fileName.lower()
			if score:
				print("%s|%s|%s|%s" % (artist_id, mod_id, fileName, score))
			else:
				print("%s|%s|%s|%s" % (artist_id, mod_id, fileName, unrated))
		sys.stdout.flush()



def top_artists():
	print("# artistid|name|score|downloads|rating|avgdownloads")

	id_name=re.compile('<a class="title" href="modules\\.php\\?(\\d+)">([^>]+)</a>', re.MULTILINE)
	artist_score=re.compile('href="modules\\.php\\?([\\d]+)">Scoring ([\\d.]+) / 10</a>', re.MULTILINE)
	artist_total=re.compile('src="style/images/icons/information\\.png"> Total downloads: ([\\d.,]+)', re.MULTILINE)
	artist_ratings=re.compile('src="style/images/icons/information\\.png"> Total ratings: ([\\d.,]+)', re.MULTILINE)
	artist_downloads=re.compile('src="style/images/icons/information\\.png"> Average Downloads per module: ([\\d.,]+)', re.MULTILINE)

	for page in range(1, 6):
		url = 'http://modarchive.org/index.php?request=view_chart&query=topartists&page=%d#mods' % page
		print("# %s" % url)
		time.sleep(1)
		response = urllib.request.urlopen(url)
		html = response.read()
		html = html.decode('utf-8')

		id_name_matches = id_name.findall(html)
		artist_score_matches = artist_score.findall(html)
		artist_total_matches = artist_total.findall(html)
		artist_ratings_matches = artist_ratings.findall(html)
		artist_downloads_matches = artist_downloads.findall(html)

		result = []
		for i in zip(id_name_matches,
			artist_score_matches,
			artist_total_matches,
			artist_ratings_matches,
			artist_downloads_matches):
			artist_id, artist_name  = i[0][0], i[0][1]
			score = int(float(i[1][1]))
			total = int(i[2].replace(',',''))
			ratings = int(i[3])
			downloads = int(i[4].replace(',',''))
			result.append((artist_id, artist_name, score, total, ratings, downloads))

		for r in result:
			print("%s|%s|%s|%s|%s|%s" % r)

def most_rated():
	m1 = re.compile('href="http://modarchive\\.org/data/downloads\\.php\\?moduleid=(\\d+)#([^\"]+)"', re.MULTILINE)
	m2 = re.compile("href='interactive\\.php\\?request=write_comment_page&amp;query=(\\d+)' class='middle'>Rated</a>([^<]+)</i>", re.MULTILINE)
	print("# modid|filename|score|maxscore")
	num_pages_by_score = {
		10:20,
		9:50,
		8:68,
		7:62,
		6:41,
		5:29,
		4:20,
		3:15,
		2:10,
		1:7}
	d = {}
	#for score in (10,9,8,7,6,5,4,3):
	for score in (1,):
		for page in range(1, num_pages_by_score[score] + 1):
			try:
				url = 'http://modarchive.org/index.php?request=view_by_rating_comments&query=%s&page=%d#mods' % (score, page)
				print("# %s" % url)
				response = urllib.request.urlopen(url)
				html = response.read()
				html = html.decode('utf-8')

				matches = m1.findall(html)
				for m in matches:
					modid = m[0]
					modname = m[1]
					d[modid] = modname.lower()

				matches = m2.findall(html)
				for m in matches:
					try:
						k = re.search('(\\d+) / (\\d+)', m[1].strip())
						modid = m[0]
						modscore = int(k.group(1))
						modhigh = int(k.group(2))
						print("%s|%s|%s|%s" % (modid, d[modid], modscore, modhigh))
					except Exception as e:
						print(e)
						print(m)
						print(matches)
						raise

			except Exception as e:
				print(e)
				print("Score: %d" % score)
				print("Page: %d" % page)
				print(d)
				raise


def most_favourited():
	m1 = re.compile('href="http://modarchive\\.org/data/downloads\\.php\\?moduleid=(\\d+)#([^\"]+)">Download</a>', re.MULTILINE)
	m2 = re.compile('href="module\\.php\\?(\\d+)#favourites">A favourite of (\\d+) members!', re.MULTILINE)

	print("# modid|filename|favourited")
	d = {}
	for page in range(1, 174):
		url = 'http://modarchive.org/index.php?format=&search_type=&query=&request=view_top_favourites&page=%d#mods' % page
		print("# %s" % url)
		sys.stdout.flush()

		response = urllib.request.urlopen(url)
		html = response.read()
		html = html.decode('utf-8')

		#time.sleep(random.randint(2,5))

		matches = m1.findall(html)
		for m in matches:
			modid = m[0]
			filename = m[1].lower()
			if modid in d:
				d[modid]['filename'] = filename
			else:
				d[modid] = {'filename':filename,
							'modid': modid}

		matches = m2.findall(html)
		for m in matches:
			modid = m[0]
			favourited = int(m[1])
			if modid in d:
				d[modid]['favourited'] = favourited
			else:
				d[modid] = {'favourited': favourited,
							'modid': modid}

	for modid, info in d.items():
		filename, favourited = info['filename'], info['favourited']
		print("%s|%s|%s" % (modid, filename, favourited))


def genres(genre_id):
	m1 = re.compile('"http://modarchive\\.org/data/downloads\\.php\\?moduleid=(\\d+)#([^\"]+)"', re.MULTILINE)
	m2 = re.compile("query=(\\d+)' class='middle'>Rated</a> (\\d+) / 10", re.MULTILINE)
	genre_ids = {
		1:"Electronic (general)",
		2:"Electronic - Ambient",
		3:"Electronic - Dance",
		6:"Electronic - Drum & Bass",
		7:"Electronic - Techno",
		8:"Video Game",
		9:"Electronic - Breakbeat",
		10:"Electronic - House",
		11:"Electronic - Progressive",
		12:"Pop (general)",
		13:"Rock (general)",
		14:"Rock - Hard",
		15:"Rock - Soft",
		18:"Country",
		19:"Blues",
		20:"Classical",
		21:"Folk",
		22:"Hip-Hop",
		24:"Ska",
		25:"Soul",
		26:"R & B",
		27:"Reggae",
		28:"Medieval",
		29:"Jazz (general)",
		30:"Jazz - Acid",
		31:"Jazz - Modern",
		32:"Funk",
		34:"Electronic - Industrial",
		35:"Punk",
		36:"Metal (general)",
		37:"Metal - Extreme",
		38:"Gothic",
		39:"Electronic - Hardcore",
		40:"Electronic - Gabber",
		41:"Other",
		42:"World",
		43:"Soundtrack",
		44:"New Age",
		45:"Comedy",
		46:"Experimental",
		47:"Spiritual",
		48:"Alternative",
		49:"Religious",
		50:"Orchestral",
		52:"Fantasy",
		53:"One Hour Compo",
		54:"Chiptune",
		55:"Demo Style",
		56:"Ballad",
		58:"Disco",
		59:"Piano",
		60:"Electronic - Jungle",
		61:"Pop - Synth",
		62:"Pop - Soft",
		63:"Trance - Acid",
		64:"Trance - Hard",
		65:"Electronic - Rave",
		66:"Trance - Goa",
		67:"Trance - Dream",
		70:"Trance - Tribal",
		71:"Trance (general)",
		72:"Christmas",
		74:"Big Band",
		75:"Swing",
		76:"Vocal Montage",
		85:"Trance - Progressive",
		99:"Electronic - IDM",
		100:"Electronic - Other",
		101:"Electronic - Minima",
		102:"Fusion",
		103:"Grunge",
		105:"Bluegrass",
		106:"Electronic - Chillout",
		107:"Easy Listening "
	}
	genre_pages = {
		1 :9,  # Electronic (general)
		2 :31, # Electronic - Ambient
		3 :29, # Electronic - Dance
		6 :7,  # Electronic - Drum & Bass
		7 :40, # Electronic - Techno
		8 :14, # Video Game
		9 :4,  # Electronic - Breakbeat
		10:6,  # Electronic - House
		11:2,  # Electronic - Progressive
		12:13, # Pop (general)
		13:14, # Rock (general)
		14:4,  # Rock - Hard
		15:6,  # Rock - Soft
		18:1,  # Country
		19:1,  # Blues
		20:2,  # Classical
		21:4,  # Folk
		22:3,  # Hip-Hop
		24:1,  # Ska
		25:1,  # Soul
		26:1,  # R & B
		27:2,  # Reggae
		28:2,  # Medieval
		29:3,  # Jazz (general)
		30:1,  # Jazz - Acid
		31:2,  # Jazz - Modern
		32:8,  # Funk
		34:4,  # Electronic - Industrial
		35:1,  # Punk
		36:15, # Metal (general)
		37:1,  # Metal - Extreme
		38:2,  # Gothic
		39:3,  # Electronic - Hardcore
		40:1,  # Electronic - Gabber
		41:7,  # Other
		42:2,  # World
		43:4,  # Soundtrack
		44:3,  # New Age
		45:1,  # Comedy
		46:8,  # Experimental
		47:1,  # Spiritual
		48:7,  # Alternative
		49:1,  # Religious
		50:10, # Orchestral
		52:8,  # Fantasy
		53:10, # One Hour Compo
		54:54, # Chiptune
		55:24, # Demo Style
		56:18, # Ballad
		58:2,  # Disco
		59:8,  # Piano
		60:2,  # Electronic - Jungle
		61:16, # Pop - Synth
		62:2,  # Pop - Soft
		63:3,  # Trance - Acid
		64:1,  # Trance - Hard
		65:6,  # Electronic - Rave
		66:4,  # Trance - Goa
		67:6,  # Trance - Dream
		70:1,  # Trance - Tribal
		71:20, # Trance (general)
		72:2,  # Christmas
		74:1,  # Big Band
		75:1,  # Swing
		76:1,  # Vocal Montage
		85:1,  # Trance - Progressive
		99:1,  # Electronic - IDM
		100:2, # Electronic - Other
		101:1, # Electronic - Minima
		102:1, # Fusion
		103:1, # Grunge,
		105:1, # Bluegrass
		106:2, # Electronic - Chillout
		107:1  # Easy Listening
	}
	print("# genre %d = %s" % (genre_id, genre_ids[genre_id]))
	print("# modid|genre|filename|score")
	d = {}
	for page in range(1, genre_pages[genre_id] + 1):
		url = 'http://modarchive.org/index.php?query=%d&request=search&search_type=genre&page=%d#mods' % (genre_id,page)
		print("# %s" % url)
		time.sleep(random.randint(2,10))

		response = urllib.request.urlopen(url)
		html = response.read()
		html = html.decode('utf-8')

		matches = m1.findall(html)
		for m in matches:
			modid = m[0]
			filename = m[1].lower()

			if modid in d:
				d[modid]['filename'] = filename
			else:
				d[modid] = {'filename':filename,
							'modid': modid}

		matches = m2.findall(html)
		for m in matches:
			modid = m[0]
			score = int(m[1])
			if modid in d:
				d[modid]['score'] = score
			else:
				d[modid] = {'score': favourited,
							'modid': modid}
	for modid, info in d.items():
		filename = info['filename']
		score = info.get('score','')
		print("%s|%d|%s|%s" % (modid, genre_id, filename, score))

def download_song(modid, fileName):
	destFile = os.path.join('zip',fileName)
	if os.path.exists(destFile):
		return
	time.sleep(random.randint(2,5))
	response = urllib.request.urlopen('http://modarchive.org/data/downloads.php?moduleid=%s' % modid)
	data = response.read()
	open(destFile, 'wb').write(data)

def download_missing_songs():
	lines = open('missing-songs.txt','r').readlines()
	for line in lines:
		line = line.rstrip()
		if line[0] == '#':
			continue
		x = line.split('|')
		modid, fileName = x
		print('Downloading %s.zip (%s)' % (fileName, modid))
		download_song(modid, fileName + ".zip")


if __name__ == '__main__':
	#most_rated()
	#most_favourited()
	#genres(105)
	#artists()
	#top_artists()
	#all_songs_by_artist(i)
	download_missing_songs()

