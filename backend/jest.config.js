module.exports = {
  moduleFileExtensions: ['js', 'json', 'ts'],
  rootDir: 'src',
  testRegex: '.*\\.spec\\.ts$',
  transform: {
    '^.+\\.(t|j)s$': 'ts-jest',
  },
  collectCoverageFrom: ['**/*.(t|j)s'],
  coverageDirectory: '../coverage',
  testEnvironment: 'node',
  moduleNameMapper: {
    '^@modules/(.*)$': '<rootDir>/modules/$1',
    '^@common/(.*)$': '<rootDir>/common/$1',
    '^@core/(.*)$': '<rootDir>/core/$1',
    '^@integrations/(.*)$': '<rootDir>/integrations/$1',
    '^@events/(.*)$': '<rootDir>/events/$1',
    '^@commands/(.*)$': '<rootDir>/commands/$1',
  },
};
