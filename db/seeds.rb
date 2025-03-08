Category.create([
  { name: 'Work', description: 'Emails related to work', user: User.first },
  { name: 'Promotions', description: 'Promotional emails', user: User.first },
  { name: 'Personal', description: 'Personal emails', user: User.first },
  { name: 'Default', description: 'when there is no perfect match', user: User.first }
])
