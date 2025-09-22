--НОРМАЛИЗАЦИЯ данных
--Создание вспомогательных таблиц
CREATE TABLE artists ( 
artist_id INTEGER PRIMARY KEY AUTOINCREMENT, 
artist_name TEXT NOT NULL UNIQUE);
CREATE TABLE regions ( 
region_code TEXT PRIMARY KEY, 
region_name TEXT NOT NULL UNIQUE);
CREATE TABLE tracks ( 
track_id INTEGER PRIMARY KEY AUTOINCREMENT, 
track_title TEXT NOT NULL, 
artist_id INTEGER NOT NULL, 
FOREIGN KEY (artist_id) REFERENCES artists(artist_id));
CREATE TABLE charts ( 
chart_id INTEGER PRIMARY KEY AUTOINCREMENT, 
chart_name TEXT NOT NULL UNIQUE);
CREATE TABLE track_urls( 
track_id INTEGER PRIMARY KEY, 
url TEXT NOT NULL, 
FOREIGN KEY (track_id) REFERENCES tracks(track_id));
--Заполним их данными из начального массива
INSERT INTO artists (artist_name)
SELECT DISTINCT artist FROM raw_spotify_data;
INSERT INTO charts (chart_name)
SELECT DISTINCT chart FROM raw_spotify_data;
INSERT INTO tracks (track_title, artist_id)
SELECT DISTINCT 
    r.title, 
    a.artist_id
FROM raw_spotify_data r
JOIN artists a ON r.artist = a.artist_name;
INSERT INTO track_urls (track_id, url)
SELECT 
    t.track_id,
    rsd.url
FROM raw_spotify_data rsd
JOIN tracks t ON rsd.title = t.track_title
GROUP BY t.track_id;
--Создадим сводную таблицу за 5 лет
CREATE TABLE chart_data_all (
    entry_id INTEGER PRIMARY KEY AUTOINCREMENT,
    track_id INTEGER NOT NULL,
    region_code TEXT NOT NULL,
    chart_id INTEGER NOT NULL,
    chart_date TEXT NOT NULL,
    track_rank INTEGER NOT NULL,
    streams INTEGER,
    trend TEXT,
    FOREIGN KEY (track_id) REFERENCES tracks(track_id),
    FOREIGN KEY (region_code) REFERENCES regions(region_code),
    FOREIGN KEY (chart_id) REFERENCES charts(chart_id)
);
--А тепреь заполним ее данными из других таблиц и начального массива
INSERT INTO chart_data_all(
track_id,
region_code,
chart_id,
chart_date,
track_rank,
streams, trend)
SELECT t.track_id,
r.region_code,
c.chart_id,
rsd.chart_date,
rsd.track_rank,
rsd.streams, rsd.trend
FROM raw_spotify_data rsd
JOIN tracks t ON t.track_title=rsd.title
JOIN regions r ON r.region_name=rsd.region
JOIN charts c ON c.chart_name=rsd.chart;
--Теперь создадим представления для chart_data_all по годам, чтобы работать только с нужными временными срезами.
CREATE VIEW v_chart_data_2017 AS
SELECT * FROM chart_data_all 
WHERE strftime('%Y', chart_date) = '2017';
CREATE VIEW v_chart_data_2018 AS
SELECT * FROM chart_data_all 
WHERE strftime('%Y', chart_date) = '2018';
CREATE VIEW v_chart_data_2019 AS
SELECT * FROM chart_data_all 
WHERE strftime('%Y', chart_date) = '2019';
CREATE VIEW v_chart_data_2020 AS
SELECT * FROM chart_data_all 
WHERE strftime('%Y', chart_date) = '2020';
CREATE VIEW v_chart_data_2021 AS
SELECT * FROM chart_data_all 
WHERE chart_date BETWEEN '2021-01-01' AND '2021-12-31';