-- Agreet App Seed Data

-- Sample categories
INSERT INTO categories (id, name, icon_url) VALUES
  ('d290f1ee-6c54-4b01-90e6-d701748f0851', 'Restaurants', 'restaurant.png'),
  ('d290f1ee-6c54-4b01-90e6-d701748f0852', 'Movies', 'movie.png'),
  ('d290f1ee-6c54-4b01-90e6-d701748f0853', 'Activities', 'activity.png'),
  ('d290f1ee-6c54-4b01-90e6-d701748f0854', 'Games', 'game.png')
ON CONFLICT (name) DO NOTHING;

-- Restaurant options
INSERT INTO options (category_id, label, image_path) VALUES
  ('d290f1ee-6c54-4b01-90e6-d701748f0851', 'Italian', 'restaurants/italian.jpeg'),
  ('d290f1ee-6c54-4b01-90e6-d701748f0851', 'Japanese', 'restaurants/japanese.jpeg'),
  ('d290f1ee-6c54-4b01-90e6-d701748f0851', 'Mexican', 'restaurants/mexican.jpeg'),
  ('d290f1ee-6c54-4b01-90e6-d701748f0851', 'Chinese', 'restaurants/chinese.jpeg'),
  ('d290f1ee-6c54-4b01-90e6-d701748f0851', 'Thai', 'restaurants/thai.jpeg'),
  ('d290f1ee-6c54-4b01-90e6-d701748f0851', 'Indian', 'restaurants/indian.jpeg'),
  ('d290f1ee-6c54-4b01-90e6-d701748f0851', 'Greek', 'restaurants/greek.jpeg'),
  ('d290f1ee-6c54-4b01-90e6-d701748f0851', 'French', 'restaurants/french.jpeg'),
  ('d290f1ee-6c54-4b01-90e6-d701748f0851', 'Korean', 'restaurants/korean.jpeg'),
  ('d290f1ee-6c54-4b01-90e6-d701748f0851', 'American', 'restaurants/american.jpeg');

-- Movie options
INSERT INTO options (category_id, label, image_path) VALUES
  ('d290f1ee-6c54-4b01-90e6-d701748f0852', 'Action', 'movies/action.jpeg'),
  ('d290f1ee-6c54-4b01-90e6-d701748f0852', 'Comedy', 'movies/comedy.jpeg'),
  ('d290f1ee-6c54-4b01-90e6-d701748f0852', 'Drama', 'movies/drama.jpeg'),
  ('d290f1ee-6c54-4b01-90e6-d701748f0852', 'Horror', 'movies/horror.jpeg'),
  ('d290f1ee-6c54-4b01-90e6-d701748f0852', 'Sci-Fi', 'movies/scifi.jpeg'),
  ('d290f1ee-6c54-4b01-90e6-d701748f0852', 'Romance', 'movies/romance.jpeg'),
  ('d290f1ee-6c54-4b01-90e6-d701748f0852', 'Thriller', 'movies/thriller.jpeg'),
  ('d290f1ee-6c54-4b01-90e6-d701748f0852', 'Animation', 'movies/animation.jpeg'),
  ('d290f1ee-6c54-4b01-90e6-d701748f0852', 'Documentary', 'movies/documentary.jpeg'),
  ('d290f1ee-6c54-4b01-90e6-d701748f0852', 'Fantasy', 'movies/fantasy.jpeg');

-- Activities options
INSERT INTO options (category_id, label, image_path) VALUES
  ('d290f1ee-6c54-4b01-90e6-d701748f0853', 'Hiking', 'activities/hiking.jpeg'),
  ('d290f1ee-6c54-4b01-90e6-d701748f0853', 'Swimming', 'activities/swimming.jpeg'),
  ('d290f1ee-6c54-4b01-90e6-d701748f0853', 'Bowling', 'activities/bowling.jpeg'),
  ('d290f1ee-6c54-4b01-90e6-d701748f0853', 'Mini Golf', 'activities/minigolf.jpeg'),
  ('d290f1ee-6c54-4b01-90e6-d701748f0853', 'Escape Room', 'activities/escaperoom.jpeg'),
  ('d290f1ee-6c54-4b01-90e6-d701748f0853', 'Karaoke', 'activities/karaoke.jpeg'),
  ('d290f1ee-6c54-4b01-90e6-d701748f0853', 'Museum', 'activities/museum.jpeg'),
  ('d290f1ee-6c54-4b01-90e6-d701748f0853', 'Board Games', 'activities/boardgames.jpeg'),
  ('d290f1ee-6c54-4b01-90e6-d701748f0853', 'Beach', 'activities/beach.jpeg'),
  ('d290f1ee-6c54-4b01-90e6-d701748f0853', 'Park', 'activities/park.jpeg');

-- Games options
INSERT INTO options (category_id, label, image_path) VALUES
  ('d290f1ee-6c54-4b01-90e6-d701748f0854', 'Minecraft', 'games/minecraft.jpeg'),
  ('d290f1ee-6c54-4b01-90e6-d701748f0854', 'Fortnite', 'games/fortnite.jpeg'),
  ('d290f1ee-6c54-4b01-90e6-d701748f0854', 'Among Us', 'games/amongus.jpeg'),
  ('d290f1ee-6c54-4b01-90e6-d701748f0854', 'Call of Duty', 'games/cod.jpeg'),
  ('d290f1ee-6c54-4b01-90e6-d701748f0854', 'FIFA', 'games/fifa.jpeg'),
  ('d290f1ee-6c54-4b01-90e6-d701748f0854', 'Mario Kart', 'games/mariokart.jpeg'),
  ('d290f1ee-6c54-4b01-90e6-d701748f0854', 'League of Legends', 'games/lol.jpeg'),
  ('d290f1ee-6c54-4b01-90e6-d701748f0854', 'Valorant', 'games/valorant.jpeg'),
  ('d290f1ee-6c54-4b01-90e6-d701748f0854', 'Roblox', 'games/roblox.jpeg'),
  ('d290f1ee-6c54-4b01-90e6-d701748f0854', 'Apex Legends', 'games/apex.jpeg');
