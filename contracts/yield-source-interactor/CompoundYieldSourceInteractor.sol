//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "../interfaces/ICToken.sol";
import "../utils/Controller.sol";

contract CompoundYieldSourceInteractor is Controller {
  event SuppliedToCompound(
    address indexed token,
    address indexed cToken,
    uint256 amount
  );
  event RedeemedFromCompound(address indexed cToken, uint256 cTokenAmount);
  event RedeemedUnderlyingFromCompound(
    address indexed cToken,
    uint256 tokenAmount
  );

  constructor(address _controller) Controller(_controller) {}

  /**
   * @notice Allow the controller to supply assets to Compound, minting cTokens
   * @param _token The address of the token supplied
   * @param _cToken The address of the corresponding cToken
   * @param _amount The amount of tokens supplied
   * @return 0 on success, otherwise an Error code
   */
  function _supplyToCompound(
    address _token,
    address _cToken,
    uint256 _amount
  ) internal returns (uint256) {
    IERC20 token = IERC20(_token);
    ICToken cToken = ICToken(_cToken);

    token.approve(_cToken, _amount);
    uint256 mintResult = cToken.mint(_amount);

    emit SuppliedToCompound(_token, _cToken, _amount);

    return mintResult;
  }

  /**
   * @notice Allow the controller to converts a specified quantity of cTokens
   * into the underlying asset, and returns them to the msg.sender
   * @param _cToken The address of the cToken
   * @param _cTokenAmount The number of cTokens to be redeemed
   * @return 0 on success, otherwise an Error code
   */
  function _redeemFromCompound(address _cToken, uint256 _cTokenAmount)
    internal
    returns (uint256)
  {
    ICToken cToken = ICToken(_cToken);

    uint256 redeemResult = cToken.redeem(_cTokenAmount);

    emit RedeemedFromCompound(_cToken, _cTokenAmount);

    return redeemResult;
  }

  /**
   * @notice Allow the controller to converts cTokens into a specified
   * quantity of the underlying asset, and returns them to the msg.sender
   * @param _cToken The address of the cToken
   * @param _tokenAmount The amount of underlying to be redeemed
   * @return 0 on success, otherwise an Error code
   */
  function _redeemUnderlyingFromCompound(address _cToken, uint256 _tokenAmount)
    internal
    returns (uint256)
  {
    ICToken cToken = ICToken(_cToken);

    uint256 redeemResult = cToken.redeemUnderlying(_tokenAmount);

    emit RedeemedUnderlyingFromCompound(_cToken, _tokenAmount);

    return redeemResult;
  }

  /**
   * @notice The user's underlying balance, representing their
   * assets in the protocol, is equal to the user's cToken balance
   * multiplied by the Exchange Rate.
   * @param _cToken The address of the cToken
   * @return The amount of underlying currently owned by this contract.
   */
  function _balanceOfUnderlyingCompound(address _cToken)
    internal
    returns (uint256)
  {
    ICToken cToken = ICToken(_cToken);
    return cToken.balanceOfUnderlying(address(this));
  }

  /**
   * @notice Get the current supply rate per block
   * @param _cToken The address of the cToken
   * @return The current supply rate as an unsigned integer, scaled by 1e18.
   */
  function _supplyRatePerBlockCompound(address _cToken)
    internal
    returns (uint256)
  {
    ICToken cToken = ICToken(_cToken);
    return cToken.supplyRatePerBlock();
  }

  /**
   * @notice Get the current exchange rate
   * @param _cToken The address of the cToken
   * @return The current exchange rate as an unsigned integer,
   * scaled by 1 * 10^(18 - 8 + Underlying Token Decimals)
   */
  function _exchangeRateCompound(address _cToken) internal returns (uint256) {
    ICToken cToken = ICToken(_cToken);
    return cToken.exchangeRateCurrent();
  }
}
