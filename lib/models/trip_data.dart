import 'package:travel_buddy_finder/models/trip.dart';

/// Temporary in-memory data for the explore feed.
/// Replace this with data from an API or database when available.
List<Trip> tripList = [
  Trip(
    id: 'kyoto',
    title: 'Kyoto Autumn Shrines & Tea Ceremony',
    location: 'Kyoto, Japan',
    price: '\$1450',
    rating: '4.8',
    hostName: 'Yuki Tanaka',
    username: '@yukitravels',
    imageUrl: 'https://images.unsplash.com/photo-1545569341-9eb8b30979d9?w=800',
    avatarUrl:
        'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=200',
    category: 'Cultural',
    description: 'Experience the breathtaking beauty of Kyoto in autumn. We will visit ancient shrines, participate in a traditional tea ceremony, and enjoy the vibrant fall colors.',
    genderPreference: 'Any (Everyone is welcome)',
    transportationMethods: ['Flight', 'Public Bus'],
  ),
  Trip(
    id: 'bali',
    title: 'Bali Beaches & Sunrise Hike',
    location: 'Bali, Indonesia',
    price: '\$980',
    rating: '4.9',
    hostName: 'Maya Putri',
    username: '@mayagoes',
    imageUrl:
        'https://images.unsplash.com/photo-1537996194471-e657df975ab4?w=800',
    avatarUrl:
        'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=200',
    category: 'Beach',
    description: 'Relax on the pristine beaches of Bali and embark on an unforgettable sunrise hike to Mount Batur. Perfect for nature lovers and beach enthusiasts.',
    genderPreference: 'Female Only',
    transportationMethods: ['Road Trip / Carpool'],
  ),
  Trip(
    id: 'santorini',
    title: 'Santorini Island Escape',
    location: 'Santorini, Greece',
    price: '\$1680',
    rating: '4.7',
    hostName: 'Nikos Papas',
    username: '@nikostravel',
    imageUrl:
        'https://images.unsplash.com/photo-1570077188670-e3a8d69ac5ff?w=800',
    avatarUrl:
        'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=200',
    category: 'Romantic',
    description: 'Enjoy a romantic escape to the stunning island of Santorini. Famous for its white-washed buildings, blue domes, and spectacular sunsets.',
    genderPreference: 'Any (Everyone is welcome)',
    transportationMethods: ['Sailing Boat'],
  ),
  Trip(
    id: 'Md Yeasin khan',
    title: 'Trey Canyon National Park',
    location: 'Moab, Utah',
    price: '\$300',
    rating: '4.9',
    hostName: 'Trey Canyon National Park',
    username: '@Treycanyonnp',
    imageUrl: 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTmYFEOgSdxdRs1wfzYf0VaG0yN8yDc_5Y-KUMTweHQ5w&s=10',
    avatarUrl:
        'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSBe9VHBu8WvoWi8MGdDYhqdUPnfD_sFiNrrA0LWuxPvA&s=10',
    category: 'Adventure',
    description: 'Explore the rugged beauty of Trey Canyon. Ideal for hiking, rock climbing, and stargazing under the vast Utah sky.',
    genderPreference: 'Male Only',
    transportationMethods: ['Road Trip / Carpool'],
  ),
  Trip(
    id: 'paris',
    title: 'Paris Trip',
    location: 'Paris, France',
    price: '\$1000',
    rating: '4.5',
    hostName: 'Pranta Nag',
    username: '@pranta',
    imageUrl: 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQRZ7PgcbbHYxpN78cTOXnEJYduVOxH11I1A2WJNGiDow&s=10',
    avatarUrl:
        'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTEt-6oY9sE8pUZV39-OyDto05yFN0fDmqSFHbZZAh1Rw&s=10',
    category: 'Cultural',
    description: 'Discover the charm of the City of Light. From the Eiffel Tower to the Louvre, experience the art, culture, and cuisine of Paris.',
    genderPreference: 'Any (Everyone is welcome)',
    transportationMethods: ['Flight', 'Bullet Train'],
  ),
  Trip(
    id: 'Kaptai',
    title: 'Kaptai Trip',
    location: 'kaptai, Rangamati',
    price: '\$1000',
    rating: '4.5',
    hostName: 'Md Yeasin khan',
    username: '@yeasin',
    imageUrl: 'https://i.postimg.cc/XNsqRVbL/kptai-fi.jpg',
    avatarUrl:
    'https://i.postimg.cc/W4FfXNcG/profile.jpg',
    category: 'Adventure',
    description: 'Explore the view of Kaptai. From the kaptai lake to the hills, experience the art, culture, and cuisine of kaptai.',
    genderPreference: 'Any (Everyone is welcome)',
    transportationMethods: ['Boat', 'Bus'],
  ),
];
